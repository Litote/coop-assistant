"""Fixtures shared by the tests and by the development seed script."""

import json
from datetime import timedelta

from odoo.tests import HttpCase

from odoo import Command

from ..controllers import main

API = "/coop_app/v1"


def create_member(env, name, login, password):
    """Create a portal user, as cooperative members are."""
    return (
        env["res.users"]
        .with_context(no_reset_password=True)
        .create(
            {
                "name": name,
                "login": login,
                "password": password,
                "groups_id": [Command.set([env.ref("base.group_portal").id])],
            }
        )
    )


def open_pos_session(env):
    """Open a session on a fresh point of sale."""
    config = env["pos.config"].create({"name": "Coop shopping API"})
    return env["pos.session"].create({"config_id": config.id, "user_id": env.uid})


def create_pos_order(env, session, partner, lines, date_order, state="paid"):
    """Record a point-of-sale ticket.

    ``lines`` is a list of ``(product, qty, unit_price_tax_included)``. The ticket
    is written directly in its final state, without payment records: enough for
    what the API reads, not for closing the session.
    """
    total = sum(qty * price for _product, qty, price in lines)
    return env["pos.order"].create(
        {
            "session_id": session.id,
            "partner_id": partner.id,
            "date_order": date_order,
            "state": state,
            "amount_tax": 0.0,
            "amount_total": total,
            "amount_paid": total,
            "amount_return": 0.0,
            "lines": [
                Command.create(
                    {
                        "product_id": product.id,
                        "full_product_name": product.display_name,
                        "qty": qty,
                        "price_unit": price,
                        "price_subtotal": qty * price,
                        "price_subtotal_incl": qty * price,
                    }
                )
                for product, qty, price in lines
            ],
        }
    )


def touch(records):
    """Stamp ``records`` as written right now.

    A test runs in one transaction, whose writes all carry the transaction's
    start time; this gives a change the write date it would have in real life.
    """
    records.flush_recordset()
    records.env.cr.execute(
        f"UPDATE {records._table} SET write_date = clock_timestamp() AT TIME ZONE 'UTC' WHERE id = ANY(%s)",  # pylint: disable=sql-injection
        [records.ids],
    )
    records.invalidate_recordset(["write_date"])


class CoopApiCase(HttpCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.alice = create_member(cls.env, "Alice Member", "alice@example.org", "alice-password-1")
        cls.bob = create_member(cls.env, "Bob Member", "bob@example.org", "bob-password-1")

    def setUp(self):
        super().setUp()
        # Exact cursors, so that tests can assert what a sync does not serve again.
        self.patch(main, "CURSOR_SAFETY_MARGIN", timedelta(0))

    def post_json(self, path, payload, token=None):
        return self.url_open(path, data=json.dumps(payload), headers=self._headers(token, json_body=True))

    def get(self, path, token=None):
        return self.url_open(path, headers=self._headers(token))

    def login(self, user_login, password):
        response = self.post_json(f"{API}/login", {"login": user_login, "password": password, "device_name": "test"})
        self.assertEqual(response.status_code, 200, response.text)
        return response.json()["token"]

    @staticmethod
    def _headers(token, json_body=False):
        headers = {"Content-Type": "application/json"} if json_body else {}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        return headers
