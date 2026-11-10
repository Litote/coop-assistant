/// One line of a point-of-sale ticket, as served by the cooperative's Odoo.
class PurchaseLine {
  const PurchaseLine({
    required this.id,
    required this.orderId,
    required this.date,
    required this.productId,
    required this.productName,
    required this.uom,
    required this.qty,
    required this.totalIncl,
    this.barcode,
  });

  final int id;
  final int orderId;

  /// Instant of the ticket.
  final DateTime date;
  final int productId;
  final String productName;
  final String? barcode;

  /// Unit of measure label ("Units", "kg"…).
  final String uom;

  /// Negative for a return.
  final double qty;

  /// Amount paid for the line, taxes included.
  final double totalIncl;
}
