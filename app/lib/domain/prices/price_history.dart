import 'package:coop_assistant/domain/model/product.dart';
import 'package:coop_assistant/domain/model/purchase_line.dart';

enum PriceSource {
  /// What the member paid at the till.
  paid,

  /// The catalogue price seen by the app.
  catalogue,
}

/// The unit price of a product from [since] on, until the next change.
class PriceChange {
  const PriceChange({required this.since, required this.price, required this.source});

  final DateTime since;
  final double price;
  final PriceSource source;
}

/// Successive prices of one product, oldest first, from what the member paid
/// ([purchases], lines of that product only) and from the catalogue prices the
/// app recorded. Only changes are kept.
///
/// A paid unit price is derived from a rounded total, so it is only known to
/// within half a cent divided by the quantity: differences inside that
/// uncertainty are not changes.
List<PriceChange> priceHistory({
  required Iterable<PurchaseLine> purchases,
  required Iterable<CataloguePrice> cataloguePrices,
}) {
  final observations = <_Observation>[
    for (final line in purchases)
      if (line.qty > 0)
        _Observation(line.date, line.totalIncl / line.qty, PriceSource.paid, uncertainty: 0.005 / line.qty),
    for (final price in cataloguePrices) _Observation(price.recordedAt, price.price, PriceSource.catalogue),
  ]..sort((a, b) => a.date.compareTo(b.date));

  final changes = <PriceChange>[];
  _Observation? current;
  for (final observation in observations) {
    if (current != null &&
        (observation.price - current.price).abs() <= observation.uncertainty + current.uncertainty + 0.005) {
      continue;
    }
    current = observation;
    changes.add(
      PriceChange(since: observation.date, price: (observation.price * 100).round() / 100, source: observation.source),
    );
  }
  return changes;
}

class _Observation {
  const _Observation(this.date, this.price, this.source, {this.uncertainty = 0});

  final DateTime date;
  final double price;
  final PriceSource source;
  final double uncertainty;
}
