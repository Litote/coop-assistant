from unittest.mock import patch

from odoo.tests import tagged

from ..controllers import main
from .common import API, CoopApiCase, touch

# A 1x1 PNG.
PIXEL = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="


@tagged("post_install", "-at_install")
class TestProducts(CoopApiCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.category = cls.env["product.category"].create({"name": "Épicerie"})
        cls.coffee = cls.env["product.product"].create(
            {
                "name": "Coffee 250g",
                "default_code": "B63",
                "barcode": "3760000000017",
                "available_in_pos": True,
                "list_price": 4.5,
                "standard_price": 3.0,
                "taxes_id": False,
                "categ_id": cls.category.id,
                "image_1920": PIXEL,
            }
        )
        cls.carrots = cls.env["product.product"].create(
            {
                "name": "Carrots",
                "available_in_pos": True,
                "list_price": 2.4,
                "taxes_id": False,
                "categ_id": cls.category.id,
                "uom_id": cls.env.ref("uom.product_uom_kgm").id,
                "uom_po_id": cls.env.ref("uom.product_uom_kgm").id,
            }
        )
        cls.backoffice = cls.env["product.product"].create(
            {"name": "Not sold at the till", "available_in_pos": False, "image_1920": PIXEL}
        )
        cls._age_products()

    @classmethod
    def _age_products(cls):
        """Make everything written so far older than what a test changes next."""
        cls.env.flush_all()
        for table in ("product_product", "product_template"):
            cls.env.cr.execute(f"UPDATE {table} SET write_date = write_date - interval '1 hour'")  # pylint: disable=sql-injection
        cls.env.invalidate_all()

    def setUp(self):
        super().setUp()
        self.token = self.login("alice@example.org", "alice-password-1")

    def products(self, cursor=None):
        response = self.get(f"{API}/products" + (f"?cursor={cursor}" if cursor else ""), self.token)
        self.assertEqual(response.status_code, 200, response.text)
        return response.json()

    def all_products(self):
        """Every product served from a first sync on, and the final cursor.

        The database may hold other products (demo data): tests look at their own.
        """
        products, cursor = [], None
        while True:
            body = self.products(cursor)
            products += body["products"]
            cursor = body["next_cursor"]
            if not body["has_more"]:
                return products, cursor

    def test_catalogue_requires_a_token_but_no_consent(self):
        self.assertEqual(self.get(f"{API}/products").status_code, 401)
        self.assertFalse(self.alice.partner_id.coop_app_purchase_consent)
        self.products()

    def test_catalogue_lists_the_products_sold_at_the_till(self):
        products, _cursor = self.all_products()
        served = {product["id"] for product in products}
        self.assertLessEqual({self.coffee.id, self.carrots.id}, served)
        self.assertNotIn(self.backoffice.id, served)
        coffee = next(product for product in products if product["id"] == self.coffee.id)
        self.assertEqual(
            coffee,
            {
                "id": self.coffee.id,
                "name": "Coffee 250g",
                "barcode": "3760000000017",
                "category": "Épicerie",
                "uom": self.coffee.uom_id.name,
                "price_incl": 4.5,
                "has_image": True,
                "active": True,
            },
        )
        carrots = next(product for product in products if product["id"] == self.carrots.id)
        self.assertEqual((carrots["uom"], carrots["barcode"], carrots["has_image"]), ("kg", None, False))

    def test_point_of_sale_category_takes_precedence(self):
        self.coffee.pos_categ_ids = self.env["pos.category"].create({"name": "Petit-déjeuner"})
        coffee = next(product for product in self.all_products()[0] if product["id"] == self.coffee.id)
        self.assertEqual(coffee["category"], "Petit-déjeuner")

    def test_price_includes_taxes(self):
        tax = self.env["account.tax"].create(
            {
                "name": "TVA 10% test",
                "amount": 10,
                "amount_type": "percent",
                "type_tax_use": "sale",
                "price_include": False,
            }
        )
        self.coffee.taxes_id = tax
        coffee = next(product for product in self.all_products()[0] if product["id"] == self.coffee.id)
        self.assertEqual(coffee["price_incl"], 4.95)

    def test_a_price_change_is_served_after_the_cursor(self):
        _products, cursor = self.all_products()
        self.assertEqual(self.products(cursor)["products"], [])
        # The price lives on the template, not on the variant the catalogue lists.
        self.coffee.product_tmpl_id.list_price = 4.9
        touch(self.coffee.product_tmpl_id)
        changed = self.products(cursor)
        self.assertEqual([(p["id"], p["price_incl"]) for p in changed["products"]], [(self.coffee.id, 4.9)])
        self.assertEqual(self.products(changed["next_cursor"])["products"], [])

    def test_archived_or_withdrawn_products_are_served_inactive_after_the_cursor(self):
        _products, cursor = self.all_products()
        self.coffee.active = False
        self.carrots.available_in_pos = False
        touch(self.coffee)
        touch(self.carrots.product_tmpl_id)
        changed = self.products(cursor)["products"]
        self.assertEqual({p["id"]: p["active"] for p in changed}, {self.coffee.id: False, self.carrots.id: False})
        # A first sync has nothing to remove: they are simply not listed.
        served = {product["id"] for product in self.all_products()[0]}
        self.assertFalse(served & {self.coffee.id, self.carrots.id})

    def test_cursor_pages_through_the_catalogue(self):
        with patch.object(main, "PRODUCT_PAGE_SIZE", 1):
            first = self.products()
            self.assertTrue(first["has_more"])
            self.assertEqual(len(first["products"]), 1)
            products, cursor = self.all_products()
            # Every page of a first sync lists the catalogue only, and what was
            # outside it is not served afterwards either.
            self.assertTrue(all(product["active"] for product in products))
            self.assertEqual(self.products(cursor)["products"], [])
        served = [product["id"] for product in products]
        self.assertLessEqual({self.coffee.id, self.carrots.id}, set(served))
        self.assertEqual(len(served), len(set(served)), "no product is served twice")

    def test_malformed_cursor_is_rejected(self):
        response = self.get(f"{API}/products?cursor=nope", self.token)
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json()["error"]["code"], "INVALID_CURSOR")

    def test_image_is_served_to_members_only(self):
        url = f"{API}/products/{self.coffee.id}/image"
        self.assertEqual(self.get(url).status_code, 401)
        response = self.get(url, self.token)
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.headers["Content-Type"].startswith("image/"))
        self.assertEqual(response.headers["Access-Control-Allow-Origin"], "*")
        self.assertTrue(response.content)

    def test_image_is_not_found_without_picture_or_outside_the_catalogue(self):
        for product_id in (self.carrots.id, self.backoffice.id, 999999999):
            response = self.get(f"{API}/products/{product_id}/image", self.token)
            self.assertEqual(response.status_code, 404, product_id)
            self.assertEqual(response.json()["error"]["code"], "NOT_FOUND")
