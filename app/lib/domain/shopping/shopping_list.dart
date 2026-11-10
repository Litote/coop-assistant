import 'package:coop_assistant/domain/model/product.dart';

/// One line of the member's shopping list.
class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.label,
    required this.quantity,
    required this.checked,
    this.productId,
  });

  final int id;

  /// Catalogue product the line is about; `null` for a free-text line.
  final int? productId;

  /// Product name when the line was added, or the text the member typed.
  final String label;
  final double quantity;

  /// Already in the basket.
  final bool checked;
}

/// A shopping list line with what the catalogue currently says about it.
class ShoppingEntry {
  const ShoppingEntry({required this.item, required this.label, required this.uom, this.unitPrice});

  final ShoppingItem item;

  /// Current catalogue name, else the name kept on the line.
  final String label;

  /// Unit of measure label; empty for a free-text line.
  final String uom;

  /// Current catalogue price of one unit; `null` when unknown (free-text
  /// line, product no longer in the catalogue).
  final double? unitPrice;

  double? get total => unitPrice == null ? null : unitPrice! * item.quantity;

  /// How much one tap on "more" or "less" changes the quantity.
  double get step => quantityStep(uom);
}

class ShoppingListView {
  const ShoppingListView({required this.toBuy, required this.inBasket});

  static const empty = ShoppingListView(toBuy: [], inBasket: []);

  /// Lines still to pick, in the order they were added.
  final List<ShoppingEntry> toBuy;

  /// Lines already checked.
  final List<ShoppingEntry> inBasket;

  Iterable<ShoppingEntry> get _all => toBuy.followedBy(inBasket);

  bool get isEmpty => toBuy.isEmpty && inBasket.isEmpty;

  /// Sum of the lines whose price is known, at today's catalogue prices.
  double get estimatedTotal => _all.fold(0, (sum, entry) => sum + (entry.total ?? 0));

  /// Lines left out of [estimatedTotal].
  int get unpricedCount => _all.where((entry) => entry.unitPrice == null).length;
}

/// Odoo's default unit, counted in whole pieces.
const kPieceUnits = {'', 'Units', 'Unit', 'Unité(s)', 'Unités', 'Unité'};

/// Pieces go one by one; anything measured (kg, L…) by tenths.
double quantityStep(String uom) => kPieceUnits.contains(uom) ? 1 : 0.1;

/// The list as shown: lines to buy first, each with the catalogue's current
/// name and price.
ShoppingListView shoppingListView(Iterable<ShoppingItem> items, Iterable<Product> catalogue) {
  final products = {for (final product in catalogue) product.id: product};
  final entries = [
    for (final item in items)
      ShoppingEntry(
        item: item,
        label: products[item.productId]?.name ?? item.label,
        uom: products[item.productId]?.uom ?? '',
        unitPrice: products[item.productId]?.priceIncl,
      ),
  ];
  return ShoppingListView(
    toBuy: [
      for (final entry in entries)
        if (!entry.item.checked) entry,
    ],
    inBasket: [
      for (final entry in entries)
        if (entry.item.checked) entry,
    ],
  );
}

/// Quantity to put on the list for a product usually bought by [usual]:
/// whole pieces, or the measured quantity to the nearest step.
double suggestedQuantity(double usual, String uom) {
  final step = quantityStep(uom);
  final rounded = step == 1 ? usual.ceilToDouble() : (usual / step).round() * step;
  return rounded < step ? step : double.parse(rounded.toStringAsFixed(2));
}

/// [quantity] moved by one step up or down, never below one step.
double steppedQuantity(double quantity, String uom, {required bool up}) {
  final step = quantityStep(uom);
  final next = quantity + (up ? step : -step);
  return next < step ? step : double.parse(next.toStringAsFixed(2));
}
