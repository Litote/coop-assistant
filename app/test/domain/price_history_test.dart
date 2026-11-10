import 'package:coop_assistant/domain/model/product.dart';
import 'package:coop_assistant/domain/model/purchase_line.dart';
import 'package:coop_assistant/domain/prices/price_history.dart';
import 'package:flutter_test/flutter_test.dart';

var _nextId = 1;

PurchaseLine _paid(int day, double total, {double qty = 1}) => PurchaseLine(
  id: _nextId++,
  orderId: _nextId,
  date: DateTime(2026, 10, day, 18),
  productId: 1,
  productName: 'Coffee',
  uom: 'Units',
  qty: qty,
  totalIncl: total,
);

CataloguePrice _seen(int day, double price) => CataloguePrice(recordedAt: DateTime(2026, 10, day, 9), price: price);

List<(int, double, PriceSource)> _history({
  List<PurchaseLine> purchases = const [],
  List<CataloguePrice> catalogue = const [],
}) => [
  for (final change in priceHistory(purchases: purchases, cataloguePrices: catalogue))
    (change.since.day, change.price, change.source),
];

void main() {
  test('without any observation there is no history', () {
    expect(_history(), isEmpty);
  });

  test('only price changes are kept, oldest first', () {
    expect(_history(purchases: [_paid(20, 4.9), _paid(1, 4.5), _paid(8, 4.5), _paid(27, 4.9)]), [
      (1, 4.5, PriceSource.paid),
      (20, 4.9, PriceSource.paid),
    ]);
  });

  test('paid prices and catalogue prices are merged in time', () {
    expect(_history(purchases: [_paid(1, 4.5), _paid(20, 4.9)], catalogue: [_seen(10, 4.7), _seen(25, 4.9)]), [
      (1, 4.5, PriceSource.paid),
      (10, 4.7, PriceSource.catalogue),
      (20, 4.9, PriceSource.paid),
    ]);
  });

  test('the unit price paid is the total divided by the quantity', () {
    expect(_history(purchases: [_paid(1, 9, qty: 2)]), [(1, 4.5, PriceSource.paid)]);
  });

  test('rounding of weighed purchases is not a price change', () {
    // 2.40 €/kg: 0.823 kg is charged 1.98 € (2.406 €/kg), 0.31 kg 0.74 € (2.387 €/kg).
    expect(_history(purchases: [_paid(1, 2.4), _paid(8, 1.98, qty: 0.823), _paid(15, 0.74, qty: 0.31)]), [
      (1, 2.4, PriceSource.paid),
    ]);
    // A real increase to 2.60 €/kg is still seen on a small quantity.
    expect(_history(purchases: [_paid(1, 2.4), _paid(8, 0.81, qty: 0.31)]), [
      (1, 2.4, PriceSource.paid),
      (8, 2.61, PriceSource.paid),
    ]);
  });

  test('returns carry no price', () {
    expect(_history(purchases: [_paid(1, 4.5), _paid(2, -4.5, qty: -1)]), [(1, 4.5, PriceSource.paid)]);
  });
}
