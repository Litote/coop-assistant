import 'dart:math' as math;

import 'package:coop_assistant/domain/prices/price_history.dart';
import 'package:coop_assistant/presentation/common/messages.dart';
import 'package:flutter/material.dart';

/// A product's unit price over time, as a step line: a price holds until the
/// next change. Pointing at the chart reads the price at that date.
class PriceChart extends StatefulWidget {
  const PriceChart({required this.changes, required this.until, required this.uom, super.key})
    : assert(changes.length > 0, 'a price chart needs at least one price');

  /// Successive prices, oldest first.
  final List<PriceChange> changes;

  /// Right edge of the time axis (today).
  final DateTime until;
  final String uom;

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  /// Horizontal position pointed at, in the widget's coordinates.
  double? _pointer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final geometry = _Geometry(widget.changes, widget.until);
    return Semantics(
      label:
          'Évolution du prix : de ${unitPriceLabel(widget.changes.first.price, widget.uom)} '
          'le ${dayLabel(widget.changes.first.since)} à ${unitPriceLabel(widget.changes.last.price, widget.uom)} '
          "aujourd'hui.",
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, 200);
          final pointed = _pointer == null ? null : geometry.changeAt(_pointer!, size);
          return MouseRegion(
            onHover: (event) => setState(() => _pointer = event.localPosition.dx),
            onExit: (_) => setState(() => _pointer = null),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => setState(() => _pointer = details.localPosition.dx),
              onHorizontalDragUpdate: (details) => setState(() => _pointer = details.localPosition.dx),
              child: SizedBox.fromSize(
                size: size,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PriceChartPainter(
                          geometry: geometry,
                          pointer: _pointer,
                          line: theme.colorScheme.primary,
                          surface: theme.colorScheme.surface,
                          grid: theme.colorScheme.outlineVariant,
                          labelStyle: theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          uom: widget.uom,
                        ),
                      ),
                    ),
                    // The value read stays in text ink, above the plot.
                    Positioned(
                      left: _Geometry.left,
                      top: 0,
                      child: Text(
                        pointed == null
                            ? 'Touchez la courbe pour lire un prix'
                            : '${unitPriceLabel(pointed.price, widget.uom)} depuis le ${dayLabel(pointed.since)}',
                        style: pointed == null
                            ? theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSurfaceVariant)
                            : theme.textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Maps dates and prices to the plot area.
class _Geometry {
  _Geometry(this.changes, DateTime until)
    : start = changes.first.since,
      // A history that starts today still gets a visible segment.
      end = until.isAfter(changes.first.since.add(const Duration(days: 1)))
          ? until
          : changes.first.since.add(const Duration(days: 1)) {
    final prices = changes.map((change) => change.price);
    final low = prices.reduce(math.min);
    final high = prices.reduce(math.max);
    final margin = high == low ? math.max(high * 0.05, 0.05) : (high - low) * 0.15;
    minPrice = low - margin;
    maxPrice = high + margin;
  }

  static const double left = 8;
  static const double right = 8;
  static const double top = 28;
  static const double bottom = 22;

  final List<PriceChange> changes;
  final DateTime start;
  final DateTime end;
  late final double minPrice;
  late final double maxPrice;

  double x(DateTime date, Size size) {
    final span = end.difference(start).inSeconds;
    final ratio = (date.difference(start).inSeconds / span).clamp(0.0, 1.0);
    return left + ratio * (size.width - left - right);
  }

  double y(double price, Size size) {
    final ratio = (price - minPrice) / (maxPrice - minPrice);
    return size.height - bottom - ratio * (size.height - top - bottom);
  }

  /// The price in force at horizontal position [dx].
  PriceChange changeAt(double dx, Size size) =>
      changes.lastWhere((change) => x(change.since, size) <= dx, orElse: () => changes.first);
}

class _PriceChartPainter extends CustomPainter {
  const _PriceChartPainter({
    required this.geometry,
    required this.pointer,
    required this.line,
    required this.surface,
    required this.grid,
    required this.labelStyle,
    required this.uom,
  });

  final _Geometry geometry;
  final double? pointer;
  final Color line;
  final Color surface;
  final Color grid;
  final TextStyle labelStyle;
  final String uom;

  @override
  void paint(Canvas canvas, Size size) {
    final changes = geometry.changes;
    final prices = changes.map((change) => change.price);
    final low = prices.reduce(math.min);
    final high = prices.reduce(math.max);
    const plotLeft = _Geometry.left;
    final plotRight = size.width - _Geometry.right;
    final baseline = size.height - _Geometry.bottom;

    // Recessive reference lines at the lowest and highest price, labelled in place.
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final price in {low, high}) {
      final y = geometry.y(price, size);
      canvas.drawLine(Offset(plotLeft, y), Offset(plotRight, y), gridPaint);
      final label = _text(unitPriceLabel(price, uom));
      // Above its line, except the lowest one when both exist.
      final above = price == high;
      label.paint(canvas, Offset(plotRight - label.width, above ? y - label.height - 2 : y + 2));
    }
    canvas.drawLine(Offset(plotLeft, baseline), Offset(plotRight, baseline), gridPaint);

    // The step line: each price holds until the next change, the last one until today.
    final path = Path()..moveTo(geometry.x(changes.first.since, size), geometry.y(changes.first.price, size));
    for (var i = 1; i < changes.length; i++) {
      final x = geometry.x(changes[i].since, size);
      path
        ..lineTo(x, geometry.y(changes[i - 1].price, size))
        ..lineTo(x, geometry.y(changes[i].price, size));
    }
    path.lineTo(plotRight, geometry.y(changes.last.price, size));
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // One marker per change, ringed with the surface so overlaps stay legible.
    for (final change in changes) {
      final center = Offset(geometry.x(change.since, size), geometry.y(change.price, size));
      canvas
        ..drawCircle(center, 6, Paint()..color = surface)
        ..drawCircle(center, 4, Paint()..color = line);
    }

    if (pointer case final dx?) {
      final x = dx.clamp(plotLeft, plotRight);
      final pointed = geometry.changeAt(x, size);
      canvas
        ..drawLine(Offset(x, _Geometry.top - 4), Offset(x, baseline), gridPaint..strokeWidth = 1.5)
        ..drawCircle(Offset(x, geometry.y(pointed.price, size)), 7, Paint()..color = surface)
        ..drawCircle(Offset(x, geometry.y(pointed.price, size)), 5, Paint()..color = line);
    }

    final startLabel = _text(dayLabel(geometry.start));
    final endLabel = _text("aujourd'hui");
    startLabel.paint(canvas, Offset(plotLeft, baseline + 4));
    if (plotRight - endLabel.width > plotLeft + startLabel.width + 12) {
      endLabel.paint(canvas, Offset(plotRight - endLabel.width, baseline + 4));
    }
  }

  TextPainter _text(String text) => TextPainter(
    text: TextSpan(text: text, style: labelStyle),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(_PriceChartPainter oldDelegate) =>
      oldDelegate.geometry.changes != geometry.changes ||
      oldDelegate.pointer != pointer ||
      oldDelegate.line != line ||
      oldDelegate.surface != surface;
}
