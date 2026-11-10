from datetime import timedelta
from unittest.mock import patch

from odoo.tests import tagged

from odoo import fields

from ..controllers import main
from .common import API, CoopApiCase, create_pos_order, open_pos_session, touch


@tagged("post_install", "-at_install")
class TestPurchases(CoopApiCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.session = open_pos_session(cls.env)
        cls.coffee = cls.env["product.product"].create(
            {"name": "Coffee 250g", "barcode": "3760000000017", "available_in_pos": True, "taxes_id": False}
        )
        cls.carrots = cls.env["product.product"].create(
            {
                "name": "Carrots",
                "available_in_pos": True,
                "taxes_id": False,
                "uom_id": cls.env.ref("uom.product_uom_kgm").id,
                "uom_po_id": cls.env.ref("uom.product_uom_kgm").id,
            }
        )
        cls.now = fields.Datetime.now()

    def order(self, user, lines, days_ago=1, state="paid"):
        return create_pos_order(
            self.env, self.session, user.partner_id, lines, self.now - timedelta(days=days_ago), state=state
        )

    def token_with_consent(self, user_login, password):
        token = self.login(user_login, password)
        response = self.post_json(f"{API}/me/consent", {"purchase_history": True}, token)
        self.assertEqual(response.status_code, 200, response.text)
        return token

    def purchases(self, token, cursor=None):
        response = self.get(f"{API}/purchases" + (f"?cursor={cursor}" if cursor else ""), token)
        self.assertEqual(response.status_code, 200, response.text)
        return response.json()

    def test_purchases_require_consent(self):
        self.order(self.alice, [(self.coffee, 1, 4.5)])
        token = self.login("alice@example.org", "alice-password-1")
        response = self.get(f"{API}/purchases", token)
        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.json()["error"]["code"], "CONSENT_REQUIRED")

    def test_consent_is_stored_and_can_be_withdrawn(self):
        token = self.login("alice@example.org", "alice-password-1")
        granted = self.post_json(f"{API}/me/consent", {"purchase_history": True}, token)
        self.assertTrue(granted.json()["purchase_history_consent"])
        self.assertTrue(self.alice.partner_id.coop_app_purchase_consent)
        self.assertTrue(self.alice.partner_id.coop_app_purchase_consent_date)
        self.post_json(f"{API}/me/consent", {"purchase_history": False}, token)
        self.assertEqual(self.get(f"{API}/purchases", token).status_code, 403)

    def test_consent_payload_must_be_a_boolean(self):
        token = self.login("alice@example.org", "alice-password-1")
        for payload in ({}, {"purchase_history": "yes"}):
            self.assertEqual(self.post_json(f"{API}/me/consent", payload, token).status_code, 400, payload)

    def test_member_reads_their_own_purchase_lines(self):
        order = self.order(self.alice, [(self.coffee, 2, 4.5), (self.carrots, 0.75, 2.4)], days_ago=3)
        body = self.purchases(self.token_with_consent("alice@example.org", "alice-password-1"))
        self.assertFalse(body["has_more"])
        coffee, carrots = sorted(body["lines"], key=lambda line: line["product_name"], reverse=True)
        self.assertEqual(
            coffee,
            {
                "id": order.lines[0].id,
                "order_id": order.id,
                "date": fields.Datetime.to_string(order.date_order),
                "product_id": self.coffee.id,
                "product_name": "Coffee 250g",
                "barcode": "3760000000017",
                "uom": self.coffee.uom_id.name,
                "qty": 2.0,
                "total_incl": 9.0,
            },
        )
        self.assertEqual(carrots["qty"], 0.75)
        self.assertEqual(carrots["uom"], "kg")
        self.assertIsNone(carrots["barcode"])
        self.assertAlmostEqual(carrots["total_incl"], 1.8)

    def test_member_never_sees_another_member_purchases(self):
        self.order(self.alice, [(self.coffee, 1, 4.5)])
        bob_order = self.order(self.bob, [(self.carrots, 1, 2.4)])
        body = self.purchases(self.token_with_consent("bob@example.org", "bob-password-1"))
        self.assertEqual({line["order_id"] for line in body["lines"]}, {bob_order.id})

    def test_unpaid_and_cancelled_tickets_are_left_out(self):
        self.order(self.alice, [(self.coffee, 1, 4.5)], state="draft")
        self.order(self.alice, [(self.coffee, 1, 4.5)], state="cancel")
        done = self.order(self.alice, [(self.coffee, 1, 4.5)], state="done")
        body = self.purchases(self.token_with_consent("alice@example.org", "alice-password-1"))
        self.assertEqual({line["order_id"] for line in body["lines"]}, {done.id})

    def test_returns_are_served_as_negative_quantities(self):
        self.order(self.alice, [(self.coffee, -1, 4.5)])
        body = self.purchases(self.token_with_consent("alice@example.org", "alice-password-1"))
        self.assertEqual([(line["qty"], line["total_incl"]) for line in body["lines"]], [(-1.0, -4.5)])

    def test_tickets_older_than_the_history_window_are_left_out(self):
        self.order(self.alice, [(self.coffee, 1, 4.5)], days_ago=800)
        recent = self.order(self.alice, [(self.coffee, 1, 4.5)], days_ago=700)
        body = self.purchases(self.token_with_consent("alice@example.org", "alice-password-1"))
        self.assertEqual({line["order_id"] for line in body["lines"]}, {recent.id})

    def test_cursor_pages_through_tickets_without_loss_or_repeat(self):
        orders = [self.order(self.alice, [(self.coffee, 1, 4.5)], days_ago=day) for day in range(1, 6)]
        token = self.token_with_consent("alice@example.org", "alice-password-1")
        seen, cursor, pages = [], None, 0
        with patch.object(main, "PURCHASE_PAGE_ORDERS", 2):
            while True:
                body = self.purchases(token, cursor)
                seen += [line["order_id"] for line in body["lines"]]
                cursor, pages = body["next_cursor"], pages + 1
                if not body["has_more"]:
                    break
        self.assertEqual(pages, 3)
        self.assertEqual(sorted(seen), sorted(order.id for order in orders))

    def test_cursor_then_serves_only_what_changed_since(self):
        self.order(self.alice, [(self.coffee, 1, 4.5)])
        pending = self.order(self.alice, [(self.carrots, 1, 2.4)], state="draft")
        token = self.token_with_consent("alice@example.org", "alice-password-1")
        cursor = self.purchases(token)["next_cursor"]
        nothing_new = self.purchases(token, cursor)
        self.assertEqual(nothing_new["lines"], [])
        self.assertEqual(nothing_new["next_cursor"], cursor)
        # A ticket created earlier but paid after the last call is not lost.
        pending.state = "paid"
        touch(pending)
        later = self.purchases(token, cursor)
        self.assertEqual([line["order_id"] for line in later["lines"]], [pending.id])
        new = self.order(self.alice, [(self.coffee, 1, 4.6)])
        touch(new)
        self.assertEqual([line["order_id"] for line in self.purchases(token, later["next_cursor"])["lines"]], [new.id])

    def test_a_ticket_committed_late_with_an_older_write_date_is_not_lost(self):
        self.patch(main, "CURSOR_SAFETY_MARGIN", timedelta(minutes=5))
        first = self.order(self.alice, [(self.coffee, 1, 4.5)])
        token = self.token_with_consent("alice@example.org", "alice-password-1")
        cursor = self.purchases(token)["next_cursor"]
        # Written by a transaction that began a minute before the sync above,
        # but was only committed after it.
        late = self.order(self.alice, [(self.carrots, 1, 2.4)])
        self.env["pos.order"].flush_model()
        self.env.cr.execute(
            "UPDATE pos_order SET write_date = write_date - interval '1 minute' WHERE id = %s", [late.id]
        )
        served = {line["order_id"] for line in self.purchases(token, cursor)["lines"]}
        self.assertIn(late.id, served)
        # The price of that safety: recent tickets are served again.
        self.assertIn(first.id, served)

    def test_malformed_cursor_is_rejected(self):
        token = self.token_with_consent("alice@example.org", "alice-password-1")
        response = self.get(f"{API}/purchases?cursor=not-a-cursor", token)
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json()["error"]["code"], "INVALID_CURSOR")

    def test_no_cashier_session_or_payment_data_leaves(self):
        self.order(self.alice, [(self.coffee, 1, 4.5)])
        line = self.purchases(self.token_with_consent("alice@example.org", "alice-password-1"))["lines"][0]
        self.assertEqual(
            set(line),
            {"id", "order_id", "date", "product_id", "product_name", "barcode", "uom", "qty", "total_incl"},
        )
