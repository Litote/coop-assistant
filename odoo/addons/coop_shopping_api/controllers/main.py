import base64
import binascii
import json
from datetime import datetime, timedelta

from dateutil.relativedelta import relativedelta
from odoo.addons.base.models.res_users import KEY_CRYPT_CONTEXT
from odoo.exceptions import AccessDenied
from odoo.http import request

from odoo import fields, http

from ..api import API_BASE, API_KEY_SCOPE, API_VERSION, CORS_ORIGIN, json_error, json_response

TOKEN_VALIDITY_DAYS = 365
PURCHASE_HISTORY_MONTHS = 24
PURCHASE_PAGE_ORDERS = 100
PRODUCT_PAGE_SIZE = 500
PAID_STATES = ("paid", "done", "invoiced")
MAX_DEVICE_NAME = 60
# A record written by a transaction still open when a sync runs carries a write
# date older than the cursor that sync hands out, and would never be served.
# Final cursors therefore never point closer to "now" than this margin: recent
# changes are served again on the next sync (clients upsert by id).
CURSOR_SAFETY_MARGIN = timedelta(minutes=5)


def _route(path, methods, auth="coop_app"):
    return http.route(
        path,
        type="http",
        auth=auth,
        methods=methods,
        csrf=False,
        cors=CORS_ORIGIN,
        save_session=False,
        # Explicit: Odoo would otherwise serve ``auth="none"`` routes read-only,
        # and logging in writes (login cooldown, device token).
        readonly=methods == ["GET"],
    )


def _json_body():
    try:
        body = json.loads(request.httprequest.get_data(as_text=True) or "{}")
    except ValueError:
        return None
    return body if isinstance(body, dict) else None


def _encode_cursor(key, bootstrap_start=None):
    """Opaque cursor for the keyset position ``key = (write_date, record_id)``.

    ``bootstrap_start`` marks a first sync still in progress, and when it began.
    """
    raw = f"{key[0].isoformat()}|{key[1]}|{bootstrap_start.isoformat() if bootstrap_start else ''}"
    return base64.urlsafe_b64encode(raw.encode()).decode()


def _decode_cursor(cursor):
    """Return ``(key, bootstrap_start)``, or ``None`` when the cursor is malformed."""
    try:
        write_date, record_id, bootstrap_start = base64.urlsafe_b64decode(cursor.encode()).decode().split("|")
        return (
            (datetime.fromisoformat(write_date), int(record_id)),
            datetime.fromisoformat(bootstrap_start) if bootstrap_start else None,
        )
    except (ValueError, binascii.Error, UnicodeDecodeError):
        return None


def _settled(key):
    """Position a final cursor may point to: ``key``, held back by the safety margin."""
    limit = request.env.cr.now() - CURSOR_SAFETY_MARGIN
    return key if key[0] <= limit else (limit, 0)


_START = (datetime.min, 0)
# What makes a product part of the shop's catalogue.
_IN_CATALOGUE = "pp.active AND pt.active AND pt.available_in_pos AND pt.sale_ok"


def _invalid_cursor():
    return json_error(400, "INVALID_CURSOR", "Unknown cursor.")


class CoopShoppingApi(http.Controller):
    @_route("/.well-known/coop-app.json", ["GET"], auth="none")
    def discovery(self):
        company = request.env["res.company"].sudo().search([], order="id", limit=1)
        module = request.env["ir.module.module"].sudo().search([("name", "=", "coop_shopping_api")])
        return json_response(
            {
                "name": company.name,
                "api_version": API_VERSION,
                "api_base": API_BASE,
                "module_version": module.installed_version,
                "features": ["purchases", "products"],
            }
        )

    @_route(f"{API_BASE}/login", ["POST"], auth="none")
    def login(self):
        body = _json_body() or {}
        login, password = body.get("login"), body.get("password")
        if not isinstance(login, str) or not isinstance(password, str) or not login or not password:
            return json_error(400, "INVALID_PAYLOAD", "login and password are required.")
        device = body.get("device_name")
        device = device.strip()[:MAX_DEVICE_NAME] if isinstance(device, str) else ""
        try:
            # Standard credential check: Odoo's login cooldown applies.
            auth_info = request.env["res.users"].authenticate(
                request.db, {"login": login, "password": password, "type": "password"}, {"interactive": False}
            )
        except AccessDenied:
            return json_error(401, "INVALID_CREDENTIALS", "Wrong login or password.")
        env = request.env(user=auth_info["uid"], su=True)
        if env.user._mfa_url():
            return json_error(
                403, "MFA_NOT_SUPPORTED", "Accounts with two-factor authentication are not supported yet."
            )
        token = env["res.users.apikeys"]._generate(
            API_KEY_SCOPE,
            f"Coop app - {device or 'device'}",
            fields.Datetime.now() + timedelta(days=TOKEN_VALIDITY_DAYS),
        )
        return json_response({"token": token})

    @_route(f"{API_BASE}/logout", ["POST"])
    def logout(self):
        token = request.httprequest.headers["Authorization"].partition(" ")[2].strip()
        request.env.cr.execute(
            "SELECT id, key FROM res_users_apikeys WHERE index = %s AND user_id = %s AND scope = %s",
            [token[:8], request.env.uid, API_KEY_SCOPE],
        )
        key_ids = [
            key_id for key_id, key_hash in request.env.cr.fetchall() if KEY_CRYPT_CONTEXT.verify(token, key_hash)
        ]
        request.env["res.users.apikeys"].browse(key_ids)._remove()
        return json_response({})

    @_route(f"{API_BASE}/me", ["GET"])
    def me(self):
        return json_response(self._me())

    @_route(f"{API_BASE}/me/consent", ["POST"])
    def consent(self):
        enabled = (_json_body() or {}).get("purchase_history")
        if not isinstance(enabled, bool):
            return json_error(400, "INVALID_PAYLOAD", "purchase_history (boolean) is required.")
        partner = request.env.user.partner_id.sudo()
        if partner.coop_app_purchase_consent != enabled:
            partner.write(
                {"coop_app_purchase_consent": enabled, "coop_app_purchase_consent_date": fields.Datetime.now()}
            )
        return json_response(self._me())

    @_route(f"{API_BASE}/purchases", ["GET"])
    def purchases(self, cursor=None):
        user = request.env.user
        if not user.partner_id.sudo().coop_app_purchase_consent:
            return json_error(403, "CONSENT_REQUIRED", "Purchase history is not enabled for this member.")
        decoded = _decode_cursor(cursor) if cursor else (_START, None)
        if decoded is None:
            return _invalid_cursor()
        after = decoded[0]
        partners = user._coop_app_purchase_partners()
        # Orders are keyed on (write_date, id): an order paid or closed after the
        # client's last call is served (again); the client upserts lines by id.
        request.env["pos.order"].flush_model()
        request.env.cr.execute(
            """
            SELECT id, write_date
              FROM pos_order
             WHERE partner_id = ANY(%s)
               AND state = ANY(%s)
               AND date_order >= %s
               AND (write_date, id) > (%s, %s)
             ORDER BY write_date, id
             LIMIT %s
            """,
            [
                partners.ids,
                list(PAID_STATES),
                fields.Datetime.now() - relativedelta(months=PURCHASE_HISTORY_MONTHS),
                after[0],
                after[1],
                PURCHASE_PAGE_ORDERS + 1,
            ],
        )
        rows = request.env.cr.fetchall()
        has_more = len(rows) > PURCHASE_PAGE_ORDERS
        rows = rows[:PURCHASE_PAGE_ORDERS]
        next_cursor = cursor
        if rows:
            last = (rows[-1][1], rows[-1][0])
            next_cursor = _encode_cursor(last if has_more else _settled(last))
        # Explicit sudo: a portal member has no access to point-of-sale records.
        # The orders above are strictly the member's own; only whitelisted
        # purchase fields leave (no cashier, session or payment data).
        orders = request.env["pos.order"].sudo().browse([row[0] for row in rows])
        lines = [
            {
                "id": line.id,
                "order_id": order.id,
                "date": fields.Datetime.to_string(order.date_order),
                "product_id": line.product_id.id,
                "product_name": line.full_product_name or line.product_id.display_name,
                "barcode": line.product_id.barcode or None,
                "uom": line.product_uom_id.name,
                "qty": line.qty,
                "total_incl": line.price_subtotal_incl,
            }
            for order in orders
            for line in order.lines
        ]
        return json_response(
            {
                "lines": lines,
                "next_cursor": next_cursor,
                "has_more": has_more,
            }
        )

    @_route(f"{API_BASE}/products", ["GET"])
    def products(self, cursor=None):
        decoded = _decode_cursor(cursor) if cursor else (_START, request.env.cr.now())
        if decoded is None:
            return _invalid_cursor()
        after, bootstrap_start = decoded
        company = request.env.company
        request.env["product.product"].flush_model()
        request.env["product.template"].flush_model()
        # Keyed on the latest of the variant's and the template's write date: the
        # name and the price live on the template. A first sync (all its pages)
        # lists the catalogue only; afterwards, products that left the catalogue
        # are served too (inactive) so the app drops them.
        request.env.cr.execute(
            f"""
            SELECT pp.id, GREATEST(pp.write_date, pt.write_date) AS changed, ({_IN_CATALOGUE}) AS in_catalogue
              FROM product_product pp
              JOIN product_template pt ON pt.id = pp.product_tmpl_id
             WHERE (GREATEST(pp.write_date, pt.write_date), pp.id) > (%s, %s)
               AND (pt.company_id IS NULL OR pt.company_id = %s)
               AND (%s OR ({_IN_CATALOGUE}))
             ORDER BY changed, pp.id
             LIMIT %s
            """,
            [after[0], after[1], company.id, bootstrap_start is None, PRODUCT_PAGE_SIZE + 1],
        )
        rows = request.env.cr.fetchall()
        has_more = len(rows) > PRODUCT_PAGE_SIZE
        rows = rows[:PRODUCT_PAGE_SIZE]
        last = (rows[-1][1], rows[-1][0]) if rows else after
        if has_more:
            next_cursor = _encode_cursor(last, bootstrap_start)
        elif bootstrap_start:
            # First sync complete: from now on, serve what changed since it began.
            next_cursor = _encode_cursor((bootstrap_start - CURSOR_SAFETY_MARGIN, 0))
        else:
            next_cursor = _encode_cursor(_settled(last)) if rows else cursor
        in_catalogue = {product_id: active for product_id, _changed, active in rows}
        # Explicit sudo: a portal member cannot read unpublished products. Only
        # the whitelisted fields below leave (never the cost or the suppliers).
        products = (
            request.env["product.product"]
            .sudo()
            .with_context(active_test=False, display_default_code=False)
            .browse(list(in_catalogue))
        )
        with_image = self._products_with_image(products)
        return json_response(
            {
                "products": [
                    {
                        "id": product.id,
                        "name": product.display_name,
                        "barcode": product.barcode or None,
                        "category": product.pos_categ_ids[:1].name or product.categ_id.name,
                        "uom": product.uom_id.name,
                        "price_incl": self._price_incl(product, company),
                        "has_image": product.id in with_image,
                        "active": in_catalogue[product.id],
                    }
                    for product in products
                ],
                "next_cursor": next_cursor,
                "has_more": has_more,
            }
        )

    @_route(f"{API_BASE}/products/<int:product_id>/image", ["GET"])
    def product_image(self, product_id):
        product = request.env["product.product"].sudo().browse(product_id).exists()
        if not (product.available_in_pos and product.sale_ok and product.image_256):
            return json_error(404, "NOT_FOUND", "No image for this product.")
        return request.env["ir.binary"]._get_image_stream_from(product, "image_256").get_response()

    @staticmethod
    def _products_with_image(products):
        """Ids of the ``products`` that have a picture, their own or their template's.

        Looked up on the attachments rather than by reading the images themselves.
        """
        request.env.cr.execute(
            """
            SELECT res_model, res_id
              FROM ir_attachment
             WHERE (res_model = 'product.product' AND res_field = 'image_variant_1920' AND res_id = ANY(%s))
                OR (res_model = 'product.template' AND res_field = 'image_1920' AND res_id = ANY(%s))
            """,
            [products.ids, products.product_tmpl_id.ids],
        )
        pictured = set(request.env.cr.fetchall())
        return {
            product.id
            for product in products
            if ("product.product", product.id) in pictured
            or ("product.template", product.product_tmpl_id.id) in pictured
        }

    @staticmethod
    def _price_incl(product, company):
        """Public price of one unit, taxes included."""
        taxes = product.taxes_id._filter_taxes_by_company(company)
        return taxes.compute_all(product.lst_price, product=product)["total_included"]

    def _me(self):
        user = request.env.user
        partner = user.partner_id.sudo()
        return {
            "name": partner.name,
            "member_number": user._coop_app_member_number(),
            "purchase_history_consent": partner.coop_app_purchase_consent,
        }
