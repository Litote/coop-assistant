from odoo.http import request
from werkzeug.exceptions import Unauthorized

from odoo import models

from ..api import API_KEY_SCOPE, json_error


class IrHttp(models.AbstractModel):
    _inherit = "ir.http"

    @classmethod
    def _auth_method_coop_app(cls):
        """Authenticate with a device token sent as ``Authorization: Bearer``.

        The token is mandatory: there is deliberately no fallback on the session
        cookie, so these CSRF-exempt routes never act on ambient browser authority.
        """
        scheme, _, token = request.httprequest.headers.get("Authorization", "").partition(" ")
        token = token.strip()
        uid = None
        if scheme.lower() == "bearer" and token:
            uid = request.env["res.users.apikeys"]._check_credentials(scope=API_KEY_SCOPE, key=token)
        if not uid:
            raise Unauthorized(response=json_error(401, "UNAUTHORIZED", "Missing or invalid token.", cors=True))
        request.update_env(user=uid)
