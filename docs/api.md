# API contract — `coop_shopping_api` (version 1)

All bodies are JSON. Errors are `{"error": {"code", "message"}}`.
Every route answers CORS requests from any origin; the API never uses cookies.

## Discovery

`GET /.well-known/coop-app.json` (public)

```json
{"name": "Le Chaudron Coop", "api_version": 1, "api_base": "/coop_app/v1",
 "module_version": "18.0.1.1.0", "features": ["purchases", "products"]}
```

The app must tolerate a module older than itself: it only uses what `features` lists.

## Authentication

`POST /coop_app/v1/login` — `{"login", "password", "device_name"?}` → `{"token"}`

- The token is an Odoo API key of scope `coop_app`, valid 365 days, one per device.
  It cannot be used on any other Odoo interface.
- `401 INVALID_CREDENTIALS` (Odoo's login cooldown applies), `400 INVALID_PAYLOAD`,
  `403 MFA_NOT_SUPPORTED` for accounts with two-factor authentication.

Every other route requires `Authorization: Bearer <token>`; otherwise
`401 UNAUTHORIZED`. A session cookie alone is never accepted.

`POST /coop_app/v1/logout` revokes the token used for the call.

## Member

`GET /coop_app/v1/me` → `{"name", "member_number", "purchase_history_consent"}`

`POST /coop_app/v1/me/consent` — `{"purchase_history": true|false}` → same body as `/me`.

## Catalogue

`GET /coop_app/v1/products?cursor=` — the products sold at the till (no consent needed).

```json
{"products": [{"id": 2, "name": "Café moulu 250g", "barcode": "3760000000017",
               "category": "Épicerie", "uom": "Units", "price_incl": 4.9,
               "has_image": true, "active": true}],
 "next_cursor": "…", "has_more": false}
```

- `price_incl` is the public price of one `uom`, taxes included. `category` is
  the point-of-sale category, else the internal one.
- A first sync (no cursor) lists the catalogue. Later syncs serve what changed;
  a product that left the catalogue (archived, withdrawn from the till) comes
  with `"active": false`: drop it.
- Same paging and cursor rules as purchases; products may be served again.
- Known limit: renaming a category or changing a tax rate does not re-serve the
  products concerned.

`GET /coop_app/v1/products/{id}/image` — the picture (256 px) of a catalogue
product with `has_image`; `404 NOT_FOUND` otherwise. Send the token as for any
other call.

## Purchases

`GET /coop_app/v1/purchases?cursor=` — the member's own point-of-sale lines.

```json
{"lines": [{"id": 1, "order_id": 1, "date": "2026-05-14 17:30:00",
            "product_id": 2, "product_name": "Café moulu 250g",
            "barcode": "3760000000017", "uom": "Units", "qty": 1.0, "total_incl": 4.5}],
 "next_cursor": "…", "has_more": false}
```

- `403 CONSENT_REQUIRED` until the member enabled the purchase history.
- Paid tickets of the last 24 months. `date` is UTC. Returns are lines with a
  negative `qty`. Unit price paid = `total_incl / qty`.
- Paging: call again with `next_cursor` while `has_more`. Keep the last
  `next_cursor` and send it on the next sync to get only what changed.
- Cursors are opaque. **A line may be served again** (its ticket changed, or
  it is recent: final cursors stay five minutes behind the server clock so that
  a write committed late is never missed): upsert by `id`.
- `400 INVALID_CURSOR`.
