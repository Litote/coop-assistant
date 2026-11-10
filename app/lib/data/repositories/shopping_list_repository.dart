import 'package:coop_assistant/data/local/app_database.dart';
import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:drift/drift.dart';

/// The member's shopping list, kept on the device only.
class ShoppingListRepository {
  ShoppingListRepository(this._db);

  final AppDatabase _db;

  /// Every line, in the order it was added.
  Stream<List<ShoppingItem>> watchItems() =>
      (_db.select(_db.shoppingItems)..orderBy([(row) => OrderingTerm(expression: row.id)])).watch().map(
        (rows) => [
          for (final row in rows)
            ShoppingItem(
              id: row.id,
              productId: row.productId,
              label: row.label,
              quantity: row.quantity,
              checked: row.checked,
            ),
        ],
      );

  /// Puts [quantity] of a catalogue product on the list; a line of that
  /// product still to buy gets the quantity added instead of a duplicate.
  Future<void> addProduct({required int productId, required String label, required double quantity}) => _addOrIncrease(
    (row) => row.productId.equals(productId),
    ShoppingItemsCompanion.insert(productId: Value(productId), label: label, quantity: quantity),
  );

  /// Adds a free-text line; blank text is ignored, a same line still to buy
  /// (whatever the letter case) gets one more.
  Future<void> addFreeLine(String text) async {
    final label = text.trim();
    if (label.isEmpty) {
      return;
    }
    await _addOrIncrease(
      (row) => row.productId.isNull() & row.label.lower().equals(label.toLowerCase()),
      ShoppingItemsCompanion.insert(label: label, quantity: 1),
    );
  }

  Future<void> _addOrIncrease(
    Expression<bool> Function($ShoppingItemsTable row) sameLine,
    ShoppingItemsCompanion line,
  ) => _db.transaction(() async {
    final existing =
        await (_db.select(_db.shoppingItems)
              ..where((row) => sameLine(row) & row.checked.equals(false))
              ..limit(1))
            .getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.shoppingItems).insert(line);
    } else {
      final quantity = double.parse((existing.quantity + line.quantity.value).toStringAsFixed(2));
      await _update(existing.id, ShoppingItemsCompanion(quantity: Value(quantity)));
    }
  });

  Future<void> setChecked(int id, {required bool checked}) =>
      _update(id, ShoppingItemsCompanion(checked: Value(checked)));

  Future<void> setQuantity(int id, double quantity) => _update(id, ShoppingItemsCompanion(quantity: Value(quantity)));

  Future<void> remove(int id) => (_db.delete(_db.shoppingItems)..where((row) => row.id.equals(id))).go();

  /// Empties the basket part of the list once the shopping is done.
  Future<void> removeChecked() => (_db.delete(_db.shoppingItems)..where((row) => row.checked.equals(true))).go();

  Future<void> clear() => _db.delete(_db.shoppingItems).go();

  Future<void> _update(int id, ShoppingItemsCompanion values) =>
      (_db.update(_db.shoppingItems)..where((row) => row.id.equals(id))).write(values);
}
