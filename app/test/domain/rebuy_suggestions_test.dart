import 'package:coop_assistant/domain/model/purchase_line.dart';
import 'package:coop_assistant/domain/suggestions/rebuy_suggestions.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = DateTime(2026, 11, 10, 9);
var _nextId = 1;

/// A purchase made [daysAgo] days before today.
PurchaseLine _line(
  int daysAgo, {
  double qty = 1,
  double unitPrice = 2,
  int productId = 1,
  String name = 'Coffee',
  int hour = 18,
}) => PurchaseLine(
  id: _nextId++,
  orderId: _nextId,
  date: DateTime(2026, 11, 10 - daysAgo, hour),
  productId: productId,
  productName: name,
  uom: 'Units',
  qty: qty,
  totalIncl: qty * unitPrice,
);

List<RebuySuggestion> _suggest(List<PurchaseLine> lines, {Set<int> hidden = const {}}) =>
    rebuySuggestions(lines, today: _today, hiddenProductIds: hidden);

void main() {
  test('a product bought every week is due once the week has passed', () {
    final suggestion = _suggest([_line(29), _line(22), _line(15), _line(8)]).single;

    expect(suggestion.status, RebuyStatus.due);
    expect(suggestion.productName, 'Coffee');
    expect(suggestion.usualIntervalDays, 7);
    expect(suggestion.usualQuantity, 1);
    expect(suggestion.lastPurchase, DateTime.utc(2026, 11, 2));
    expect(suggestion.expectedOn, DateTime.utc(2026, 11, 9));
  });

  test('it is announced shortly before running out, not earlier', () {
    expect(_suggest([_line(27), _line(20), _line(13), _line(6)]).single.status, RebuyStatus.soon);
    expect(_suggest([_line(26), _line(19), _line(12), _line(5)]), isEmpty);
  });

  test('fewer than three purchase days show no rhythm', () {
    expect(_suggest([_line(30), _line(15)]), isEmpty);
  });

  test('two tickets on the same day are one purchase', () {
    expect(_suggest([_line(30), _line(15, hour: 10), _line(15, hour: 19)]), isEmpty);
  });

  test('a larger last purchase lasts proportionally longer', () {
    List<PurchaseLine> stockedUp(int daysAgo) => [_line(daysAgo + 14), _line(daysAgo + 7), _line(daysAgo, qty: 3)];

    expect(_suggest(stockedUp(10)), isEmpty);
    final due = _suggest(stockedUp(21)).single;
    expect(due.status, RebuyStatus.due);
    expect(due.expectedOn, DateTime.utc(2026, 11, 10));
    expect(due.usualQuantity, 1);
  });

  test('a product given up is no longer suggested', () {
    expect(_suggest([_line(35), _line(28), _line(21)]).single.status, RebuyStatus.due);
    expect(_suggest([_line(36), _line(29), _line(22)]), isEmpty);
  });

  test('returns are deducted and a fully returned purchase does not count', () {
    final partlyReturned = _suggest([_line(22, qty: 2), _line(22, qty: -1, hour: 19), _line(15), _line(8)]);
    expect(partlyReturned.single.usualIntervalDays, 7);
    expect(partlyReturned.single.expectedOn, DateTime.utc(2026, 11, 9));

    final fullyReturned = _suggest([_line(22), _line(15), _line(8), _line(8, qty: -1, hour: 19)]);
    expect(fullyReturned, isEmpty);
  });

  test('a hidden product is not suggested', () {
    expect(_suggest([_line(29), _line(22), _line(15), _line(8)], hidden: {1}), isEmpty);
  });

  test('products sold by weight use the quantity bought', () {
    final suggestion = _suggest([
      _line(21, qty: 0.5, unitPrice: 4),
      _line(14, qty: 1.5, unitPrice: 4),
      _line(7, qty: 1, unitPrice: 4.4),
    ]).single;

    // 2 kg consumed in 14 days: the last kilogram lasts 7 days.
    expect(suggestion.status, RebuyStatus.due);
    expect(suggestion.expectedOn, DateTime.utc(2026, 11, 10));
    expect(suggestion.usualQuantity, 1);
    expect(suggestion.lastUnitPrice, closeTo(4.4, 1e-9));
  });

  test('due products come first, the most overdue on top', () {
    final suggestions = _suggest([
      for (final days in [27, 20, 13, 6]) _line(days, productId: 1, name: 'Soon'),
      for (final days in [29, 22, 15, 8]) _line(days, productId: 2, name: 'Due'),
      for (final days in [31, 24, 17, 10]) _line(days, productId: 3, name: 'Overdue'),
    ]);

    expect(suggestions.map((s) => s.productName), ['Overdue', 'Due', 'Soon']);
  });

  test('the name and unit are those of the latest purchase', () {
    final lines = [_line(29, name: 'Old name'), _line(22, name: 'Old name'), _line(15), _line(8, name: 'New name')];
    expect(_suggest(lines).single.productName, 'New name');
  });
}
