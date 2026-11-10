"""Wire helpers shared by the controllers and the auth method."""

import json

from odoo.http import Response

API_VERSION = 1
API_BASE = "/coop_app/v1"
# Scope of the device tokens: such a key is useless for the rest of Odoo (RPC…).
API_KEY_SCOPE = "coop_app"
# The API never relies on cookies, so any origin may call it (the web app is
# hosted outside Odoo). Odoo adds this header itself on dispatched responses.
CORS_ORIGIN = "*"


def json_response(payload, status=200):
    return Response(
        json.dumps(payload),
        status=status,
        content_type="application/json; charset=utf-8",
    )


def json_error(status, code, message, *, cors=False):
    """Error body ``{"error": {"code", "message"}}``.

    ``cors=True`` is for responses raised before dispatch (authentication), which
    Odoo does not decorate with the route's CORS header.
    """
    response = json_response({"error": {"code": code, "message": message}}, status=status)
    if cors:
        response.headers["Access-Control-Allow-Origin"] = CORS_ORIGIN
    return response
