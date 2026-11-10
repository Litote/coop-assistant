from odoo import models


class ResUsers(models.Model):
    _inherit = "res.users"

    def _coop_app_purchase_partners(self):
        """Partners whose point-of-sale purchases belong to this user.

        Extension point: a cooperative whose household members shop under several
        partner records overrides this in a glue module.
        """
        self.ensure_one()
        return self.partner_id

    def _coop_app_member_number(self):
        """Member number shown in the app. Extension point, like the above."""
        self.ensure_one()
        return self.partner_id.ref or None
