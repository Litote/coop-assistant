from odoo.tests import tagged

from odoo import fields

from ..api import API_KEY_SCOPE
from .common import API, CoopApiCase


@tagged("post_install", "-at_install")
class TestAuth(CoopApiCase):
    def test_discovery_is_public(self):
        response = self.get("/.well-known/coop-app.json")
        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertEqual(body["api_version"], 1)
        self.assertEqual(body["api_base"], API)
        self.assertIn("purchases", body["features"])
        self.assertTrue(body["name"])

    def test_login_returns_a_token_that_authenticates(self):
        token = self.login("alice@example.org", "alice-password-1")
        response = self.get(f"{API}/me", token)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.json(),
            {"name": "Alice Member", "member_number": None, "purchase_history_consent": False},
        )

    def test_login_with_wrong_password_is_rejected(self):
        response = self.post_json(f"{API}/login", {"login": "alice@example.org", "password": "nope"})
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.json()["error"]["code"], "INVALID_CREDENTIALS")

    def test_login_without_credentials_is_an_invalid_payload(self):
        for payload in ({}, {"login": "alice@example.org"}, {"login": 3, "password": "x"}, ["not", "an", "object"]):
            response = self.post_json(f"{API}/login", payload)
            self.assertEqual(response.status_code, 400, payload)
            self.assertEqual(response.json()["error"]["code"], "INVALID_PAYLOAD")

    def test_request_without_token_is_unauthorized(self):
        response = self.get(f"{API}/me")
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.json()["error"]["code"], "UNAUTHORIZED")

    def test_session_cookie_alone_is_unauthorized(self):
        self.authenticate("alice@example.org", "alice-password-1")
        self.assertEqual(self.get(f"{API}/me").status_code, 401)

    def test_unknown_token_is_unauthorized(self):
        self.assertEqual(self.get(f"{API}/me", "0" * 40).status_code, 401)

    def test_key_of_another_scope_is_unauthorized(self):
        rpc_key = self.env(user=self.alice, su=True)["res.users.apikeys"]._generate(
            "rpc", "rpc key", fields.Datetime.add(fields.Datetime.now(), days=1)
        )
        self.assertEqual(self.get(f"{API}/me", rpc_key).status_code, 401)

    def test_expired_token_is_unauthorized(self):
        token = self.login("alice@example.org", "alice-password-1")
        self.env["res.users.apikeys"].sudo().search(
            [("user_id", "=", self.alice.id)]
        ).expiration_date = fields.Datetime.subtract(fields.Datetime.now(), days=1)
        self.env.flush_all()
        self.assertEqual(self.get(f"{API}/me", token).status_code, 401)

    def test_token_is_scoped_and_expires(self):
        self.login("alice@example.org", "alice-password-1")
        key = self.env["res.users.apikeys"].sudo().search([("user_id", "=", self.alice.id)])
        self.assertEqual(key.scope, API_KEY_SCOPE)
        self.assertTrue(key.expiration_date)

    def test_logout_revokes_only_the_token_used(self):
        phone = self.login("alice@example.org", "alice-password-1")
        tablet = self.login("alice@example.org", "alice-password-1")
        self.assertEqual(self.post_json(f"{API}/logout", {}, phone).status_code, 200)
        self.assertEqual(self.get(f"{API}/me", phone).status_code, 401)
        self.assertEqual(self.get(f"{API}/me", tablet).status_code, 200)

    def test_cors_lets_another_origin_send_the_token(self):
        preflight = self.opener.options(
            self.base_url() + f"{API}/me",
            headers={"Origin": "https://app.example.org", "Access-Control-Request-Headers": "authorization"},
        )
        self.assertEqual(preflight.status_code, 204)
        self.assertEqual(preflight.headers["Access-Control-Allow-Origin"], "*")
        self.assertIn("Authorization", preflight.headers["Access-Control-Allow-Headers"])
        # Exactly one header value, on successes and on errors alike.
        token = self.login("alice@example.org", "alice-password-1")
        for response in (self.get(f"{API}/me", token), self.get(f"{API}/me"), self.get(f"{API}/purchases", token)):
            self.assertEqual(response.headers["Access-Control-Allow-Origin"], "*", response.status_code)
        self.assertNotIn("Access-Control-Allow-Credentials", preflight.headers)

    def test_api_calls_do_not_open_a_session(self):
        token = self.login("alice@example.org", "alice-password-1")
        self.assertNotIn("Set-Cookie", self.get(f"{API}/me", token).headers)
