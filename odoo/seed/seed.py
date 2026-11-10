"""Development data: members, products and six months of point-of-sale tickets.

Run inside ``odoo shell`` (see README). Safe to run again: it does nothing when
the first member already exists.
"""
# ruff: noqa: F821 - ``env`` is provided by odoo shell

import base64
import random
import struct
import zlib
from datetime import timedelta

from odoo import fields
from odoo.addons.coop_shopping_api.tests.common import create_member, create_pos_order, open_pos_session

HISTORY_DAYS = 180
# name, barcode, unit price, price after the mid-period increase, sold by weight
PRODUCTS = [
    ("Café moulu 250g", "3760000000017", 4.50, 4.90, False),
    ("Pâtes complètes 500g", "3760000000024", 1.85, 1.85, False),
    ("Lait demi-écrémé 1L", "3760000000031", 1.20, 1.25, False),
    ("Beurre doux 250g", "3760000000048", 3.10, 3.40, False),
    ("Œufs x6", "3760000000055", 2.60, 2.60, False),
    ("Farine T65 1kg", "3760000000062", 1.70, 1.70, False),
    ("Huile d'olive 75cl", "3760000000079", 9.80, 10.90, False),
    ("Lessive liquide 2L", "3760000000086", 8.40, 8.40, False),
    ("Papier toilette x6", "3760000000093", 3.90, 3.90, False),
    ("Chocolat noir 100g", "3760000000109", 2.30, 2.50, False),
    ("Carottes", None, 2.40, 2.40, True),
    ("Pommes", None, 3.20, 2.90, True),
    ("Lentilles vertes (vrac)", None, 4.60, 4.60, True),
]
# login -> {product name: (days between purchases, usual quantity)}
MEMBERS = {
    "alice@example.org": {
        "Café moulu 250g": (21, 1),
        "Lait demi-écrémé 1L": (7, 2),
        "Œufs x6": (10, 1),
        "Carottes": (7, 0.8),
        "Lessive liquide 2L": (60, 1),
        "Chocolat noir 100g": (14, 2),
    },
    "bob@example.org": {
        "Pâtes complètes 500g": (14, 3),
        "Beurre doux 250g": (12, 1),
        "Pommes": (7, 1.5),
        "Huile d'olive 75cl": (75, 1),
        "Papier toilette x6": (30, 1),
    },
    "chloe@example.org": {
        "Farine T65 1kg": (20, 1),
        "Lentilles vertes (vrac)": (25, 0.5),
        "Café moulu 250g": (30, 2),
        # Bought regularly, then given up three months ago.
        "Lait demi-écrémé 1L": (7, 1),
    },
}
GIVEN_UP = {("chloe@example.org", "Lait demi-écrémé 1L"): 90}

if env["res.users"].search_count([("login", "=", "alice@example.org")]):
    print("Seed already applied.")
else:
    random.seed(18)
    kg = env.ref("uom.product_uom_kgm")
    products = {}
    for name, barcode, price, _later_price, by_weight in PRODUCTS:
        values = {"name": name, "barcode": barcode, "list_price": price, "available_in_pos": True, "taxes_id": False}
        if by_weight:
            values.update(uom_id=kg.id, uom_po_id=kg.id)
        products[name] = env["product.product"].create(values)
    prices = {name: (price, later_price) for name, _barcode, price, later_price, _w in PRODUCTS}
    session = open_pos_session(env)
    today = fields.Datetime.now().replace(hour=17, minute=30, second=0, microsecond=0)
    tickets = 0
    for login, habits in MEMBERS.items():
        member = create_member(env, login.split("@")[0].capitalize(), login, "coop-password-1")
        member.partner_id.coop_app_purchase_consent = True
        last_bought = {}
        for days_ago in range(HISTORY_DAYS, 0, -1):
            lines = []
            for name, (interval, qty) in habits.items():
                if days_ago <= GIVEN_UP.get((login, name), 0):
                    continue
                due_in = (
                    interval
                    + random.choice((-1, 0, 0, 1))
                    - (last_bought.get(name, HISTORY_DAYS + interval) - days_ago)
                )
                if due_in <= 0:
                    price = prices[name][0 if days_ago > HISTORY_DAYS // 2 else 1]
                    quantity = round(qty * random.uniform(0.8, 1.2), 3) if products[name].uom_id == kg else qty
                    lines.append((products[name], quantity, price))
                    last_bought[name] = days_ago
            if lines:
                create_pos_order(env, session, member.partner_id, lines, today - timedelta(days=days_ago))
                tickets += 1
    for name, (_price, later_price) in prices.items():
        products[name].list_price = later_price
    env.cr.commit()
    print(f"Seeded {len(products)} products, {len(MEMBERS)} members, {tickets} tickets.")


# Catalogue details, applied on every run (also to a database seeded earlier).
CATEGORIES = {
    "Épicerie": [
        "Café moulu 250g",
        "Pâtes complètes 500g",
        "Farine T65 1kg",
        "Huile d'olive 75cl",
        "Chocolat noir 100g",
    ],
    "Frais": ["Lait demi-écrémé 1L", "Beurre doux 250g", "Œufs x6"],
    "Fruits et légumes": ["Carottes", "Pommes"],
    "Vrac": ["Lentilles vertes (vrac)"],
    "Entretien": ["Lessive liquide 2L", "Papier toilette x6"],
}


def plain_png(red, green, blue, size=64):
    """A square of one colour, as a base64 PNG."""

    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    rows = (b"\x00" + bytes((red, green, blue)) * size) * size
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0))
    return base64.b64encode(png + chunk(b"IDAT", zlib.compress(rows)) + chunk(b"IEND", b""))


for category_name, product_names in CATEGORIES.items():
    category = env["pos.category"].search([("name", "=", category_name)], limit=1) or env["pos.category"].create(
        {"name": category_name}
    )
    for product in env["product.product"].search([("name", "in", product_names)]):
        if product.pos_categ_ids != category:
            product.pos_categ_ids = category
coffee = env["product.product"].search([("name", "=", "Café moulu 250g")], limit=1)
if coffee and not coffee.image_1920:
    coffee.image_1920 = plain_png(111, 78, 55)
env.cr.commit()
print("Catalogue details applied.")
