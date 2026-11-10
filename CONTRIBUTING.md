# Contributing

## Licence of contributions

coop-assistant is distributed under the GNU AGPL version 3 with an additional
permission allowing distribution through app stores
([`LICENSE`](LICENSE), [`LICENSE-EXCEPTION.md`](LICENSE-EXCEPTION.md)).

Every contribution is made under those same terms — AGPL-3.0 **with** the
additional permission. There is no contributor agreement to sign: certify the
[Developer Certificate of Origin](https://developercertificate.org/) by adding a
sign-off line to each commit:

```
Signed-off-by: Your Name <you@example.org>
```

`git commit -s` adds it for you.

## Dependencies

The additional permission only covers this project's own code. Do not add a
GPL or AGPL dependency to the app (`app/`) unless it carries an equivalent
permission: the result could no longer be published on the App Store.

## Layout and rules

- `odoo/addons/coop_shopping_api/` — the Odoo module. It stays thin: it
  authenticates, filters and returns raw data. Every `sudo()` must be filtered
  on the calling member and return whitelisted fields only.
- `app/` — the Flutter app. Computations (suggestions, price history) live here.
- `docs/api.md` is the contract between both; update it with any API change.
- Write the test first when fixing a bug; add tests for every logic change.
- Code, comments and documentation in English; the app's interface in French.
