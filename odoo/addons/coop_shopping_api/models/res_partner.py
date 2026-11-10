from odoo import fields, models


class ResPartner(models.Model):
    _inherit = "res.partner"

    coop_app_purchase_consent = fields.Boolean(
        string="Shopping app: purchase history enabled",
        help="The member agreed to let the shopping assistant app read their own purchase history.",
        copy=False,
    )
    coop_app_purchase_consent_date = fields.Datetime(
        string="Shopping app: consent changed on",
        copy=False,
        readonly=True,
    )
