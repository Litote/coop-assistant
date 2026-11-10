import 'package:coop_assistant/domain/model/product.dart';
import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:flutter_test/flutter_test.dart';

const _catalogue = [
  Product(id: 5, name: 'Café moulu 250g', category: 'Épicerie', uom: 'Units', priceIncl: 4.9),
  Product(id: 7, name: 'Carottes', category: 'Fruits et légumes', uom: 'kg', priceIncl: 2.4),
];

ShoppingItem _item(int id, String label, {int? productId, double quantity = 1, bool checked = false}) =>
    ShoppingItem(id: id, label: label, productId: productId, quantity: quantity, checked: checked);

void main() {
  test('lines to buy come first, in the order they were added', () {
    final view = shoppingListView([
      _item(1, 'Pain'),
      _item(2, 'Café', productId: 5, checked: true),
      _item(3, 'Carottes', productId: 7),
    ], _catalogue);

    expect(view.toBuy.map((entry) => entry.item.id), [1, 3]);
    expect(view.inBasket.map((entry) => entry.item.id), [2]);
    expect(view.isEmpty, isFalse);
    expect(shoppingListView(const [], _catalogue).isEmpty, isTrue);
  });

  test('a product line follows the catalogue name, unit and price', () {
    final entry = shoppingListView([_item(1, 'Old name', productId: 5, quantity: 2)], _catalogue).toBuy.single;

    expect(
      (entry.label, entry.uom, entry.unitPrice, entry.total, entry.step),
      ('Café moulu 250g', 'Units', 4.9, 9.8, 1),
    );
  });

  test('a free line or a product gone from the catalogue keeps its label and has no price', () {
    final view = shoppingListView([_item(1, 'Pain'), _item(2, 'Ancien produit', productId: 99)], _catalogue);

    expect(view.toBuy.map((entry) => (entry.label, entry.unitPrice, entry.total)), [
      ('Pain', null, null),
      ('Ancien produit', null, null),
    ]);
  });

  test('the estimated total covers every priced line, checked or not', () {
    final view = shoppingListView([
      _item(1, 'Café', productId: 5, quantity: 2),
      _item(2, 'Carottes', productId: 7, quantity: 0.5, checked: true),
      _item(3, 'Pain'),
    ], _catalogue);

    expect(view.estimatedTotal, closeTo(11, 1e-9));
    expect(view.unpricedCount, 1);
  });

  test('pieces are counted one by one, measured products by tenths', () {
    expect(quantityStep('Units'), 1);
    expect(quantityStep(''), 1);
    expect(quantityStep('kg'), 0.1);
  });

  test('the quantity suggested from a habit is a whole number of pieces or a measured quantity', () {
    expect(suggestedQuantity(1.5, 'Units'), 2);
    expect(suggestedQuantity(2, 'Units'), 2);
    expect(suggestedQuantity(0.83, 'kg'), 0.8);
    expect(suggestedQuantity(0.02, 'kg'), 0.1);
  });

  test('stepping a quantity never goes below one step', () {
    expect(steppedQuantity(2, 'Units', up: true), 3);
    expect(steppedQuantity(1, 'Units', up: false), 1);
    expect(steppedQuantity(0.3, 'kg', up: false), 0.2);
    expect(steppedQuantity(0.1, 'kg', up: false), 0.1);
    expect(steppedQuantity(0.7, 'kg', up: true), 0.8);
  });
}
