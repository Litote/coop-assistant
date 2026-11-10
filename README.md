# coop-assistant

A free shopping assistant for cooperative supermarkets running Odoo: shopping
list, price tracking and "time to buy again" suggestions computed from a
member's own purchases.

| Path | Content |
|------|---------|
| `odoo/addons/coop_shopping_api/` | Odoo 18 module: a thin, read-mostly API for the app |
| `odoo/seed/` | Development data (members, products, six months of tickets) |
| `app/` | Flutter app (mobile + web) |
| `docs/api.md` | API contract, the source of truth for both sides |

Design rule: the module only authenticates, filters and returns raw data. Every
computation (suggestions, price history) lives in the app, so it can evolve
without redeploying the module on a cooperative's Odoo.

## Local Odoo 18

```sh
cd odoo
docker compose up -d db
# Create the dev database, then load the development data
docker compose run --rm odoo odoo -d dev -i coop_shopping_api --without-demo=all --stop-after-init
docker compose run --rm -T odoo odoo shell -d dev --no-http < seed/seed.py
docker compose up -d odoo        # http://localhost:8069
```

Seeded members: `alice@example.org`, `bob@example.org`, `chloe@example.org`,
password `coop-password-1` (Odoo administrator: `admin` / `admin`).

## Tests

```sh
cd odoo
docker compose run --rm odoo odoo -d test_coop -i coop_shopping_api \
  --test-enable --test-tags /coop_shopping_api --stop-after-init
```

## App

```sh
cd app
flutter pub get
dart run build_runner build   # regenerates the drift code after a schema change
flutter test
flutter run -d chrome         # then enter http://localhost:8069 as the cooperative's address
```

`flutter test` skips the end-to-end check against a real Odoo; run it against
the seeded local instance with:

```sh
COOP_ODOO_URL=http://localhost:8069 flutter test test/integration
```

The Flutter version is pinned in `app/.flutter-version`. On an Android emulator
the local Odoo is at `http://10.0.2.2:8069`.

## Licence

GNU AGPL version 3, with an additional permission (section 7) allowing
distribution through app stores: see [`LICENSE`](LICENSE) and
[`LICENSE-EXCEPTION.md`](LICENSE-EXCEPTION.md). Contributions are accepted under
the same terms with a DCO sign-off — see [`CONTRIBUTING.md`](CONTRIBUTING.md).
