/// A product of the cooperative's shop catalogue.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.uom,
    required this.priceIncl,
    this.barcode,
    this.hasImage = false,
  });

  final int id;
  final String name;
  final String? barcode;
  final String category;

  /// Unit of measure label ("Units", "kg"…).
  final String uom;

  /// Current public price of one unit, taxes included.
  final double priceIncl;

  /// Whether the cooperative published a picture of the product.
  final bool hasImage;
}

/// A catalogue price observed by this device during a sync.
class CataloguePrice {
  const CataloguePrice({required this.recordedAt, required this.price});

  final DateTime recordedAt;
  final double price;
}
