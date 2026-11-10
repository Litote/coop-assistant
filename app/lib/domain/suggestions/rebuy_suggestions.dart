import 'package:coop_assistant/domain/model/purchase_line.dart';

enum RebuyStatus { due, soon }

/// A product the member is about to run out of, judging by their purchases.
class RebuySuggestion {
  const RebuySuggestion({
    required this.productId,
    required this.productName,
    required this.uom,
    required this.status,
    required this.lastPurchase,
    required this.expectedOn,
    required this.usualIntervalDays,
    required this.usualQuantity,
    this.lastUnitPrice,
  });

  final int productId;
  final String productName;
  final String uom;
  final RebuyStatus status;

  /// Day of the last purchase.
  final DateTime lastPurchase;

  /// Day the last purchase is estimated to run out.
  final DateTime expectedOn;
  final int usualIntervalDays;
  final double usualQuantity;

  /// Unit price paid at the last purchase, taxes included.
  final double? lastUnitPrice;
}

/// A product needs at least this many purchase days to show a rhythm.
const int kMinPurchaseDays = 3;

/// A product is announced once this share of its estimated duration has elapsed.
const double kSoonRatio = 0.8;

/// Beyond this many usual durations without a purchase, the member has
/// presumably given the product up: it is no longer suggested.
const int kAbandonedFactor = 3;

/// Products to buy again as of [today], the most overdue first.
///
/// Per product, the consumption rate is what was bought before the last
/// purchase divided by the time between the first and the last purchase; the
/// last purchase is then expected to last `last quantity / rate` days. Returns
/// are deducted from the day they were made on.
List<RebuySuggestion> rebuySuggestions(
  Iterable<PurchaseLine> lines, {
  required DateTime today,
  Set<int> hiddenProductIds = const {},
}) {
  final byProduct = <int, List<PurchaseLine>>{};
  for (final line in lines) {
    if (!hiddenProductIds.contains(line.productId)) {
      byProduct.putIfAbsent(line.productId, () => []).add(line);
    }
  }
  final todayDay = _day(today);
  final suggestions = <RebuySuggestion>[];
  for (final productLines in byProduct.values) {
    final suggestion = _suggestionFor(productLines, todayDay);
    if (suggestion != null) {
      suggestions.add(suggestion);
    }
  }
  return suggestions..sort((a, b) {
    final byStatus = a.status.index.compareTo(b.status.index);
    return byStatus != 0 ? byStatus : a.expectedOn.compareTo(b.expectedOn);
  });
}

RebuySuggestion? _suggestionFor(List<PurchaseLine> lines, DateTime today) {
  final quantityByDay = <DateTime, double>{};
  final amountByDay = <DateTime, double>{};
  for (final line in lines) {
    final day = _day(line.date);
    quantityByDay[day] = (quantityByDay[day] ?? 0) + line.qty;
    amountByDay[day] = (amountByDay[day] ?? 0) + line.totalIncl;
  }
  final days = quantityByDay.keys.where((day) => quantityByDay[day]! > 0).toList()..sort();
  if (days.length < kMinPurchaseDays) {
    return null;
  }
  final lastDay = days.last;
  final quantities = [for (final day in days) quantityByDay[day]!];
  final boughtBeforeLast = quantities.take(quantities.length - 1).fold<double>(0, (sum, qty) => sum + qty);
  final dailyRate = boughtBeforeLast / lastDay.difference(days.first).inDays;
  final lastsDays = quantities.last / dailyRate;
  final gaps = [for (var i = 1; i < days.length; i++) days[i].difference(days[i - 1]).inDays.toDouble()];
  final usualInterval = _median(gaps);
  final elapsed = today.difference(lastDay).inDays;
  final usualDuration = lastsDays > usualInterval ? lastsDays : usualInterval;
  if (elapsed < lastsDays * kSoonRatio || elapsed > usualDuration * kAbandonedFactor) {
    return null;
  }
  final latest = lines.reduce((a, b) => b.date.isAfter(a.date) ? b : a);
  return RebuySuggestion(
    productId: latest.productId,
    productName: latest.productName,
    uom: latest.uom,
    status: elapsed >= lastsDays ? RebuyStatus.due : RebuyStatus.soon,
    lastPurchase: lastDay,
    expectedOn: lastDay.add(Duration(days: lastsDays.round())),
    usualIntervalDays: usualInterval.round(),
    usualQuantity: _median(quantities),
    lastUnitPrice: amountByDay[lastDay]! / quantities.last,
  );
}

/// Calendar day of [instant] in the device's time zone, as a UTC date so that
/// day arithmetic is immune to daylight-saving shifts.
DateTime _day(DateTime instant) {
  final local = instant.toLocal();
  return DateTime.utc(local.year, local.month, local.day);
}

double _median(List<double> values) {
  final sorted = [...values]..sort();
  final middle = sorted.length ~/ 2;
  return sorted.length.isOdd ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2;
}
