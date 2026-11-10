import 'package:coop_assistant/domain/prices/price_history.dart';
import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:coop_assistant/presentation/common/messages.dart';
import 'package:coop_assistant/presentation/common/product_image.dart';
import 'package:coop_assistant/presentation/product/price_chart.dart';
import 'package:coop_assistant/presentation/product/product_cubit.dart';
import 'package:coop_assistant/presentation/shopping/add_to_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A product: its current price and how it moved.
class ProductScreen extends StatelessWidget {
  const ProductScreen({required this.productId, this.now = DateTime.now, super.key});

  final int productId;
  final DateTime Function() now;

  @override
  Widget build(BuildContext context) => BlocBuilder<ProductCubit, ProductState>(
    builder: (context, state) => Scaffold(
      appBar: AppBar(title: Text(state.name ?? 'Produit')),
      body: !state.loaded
          ? const SizedBox.shrink()
          : state.name == null
          ? const Center(child: Text("Ce produit n'est plus au catalogue."))
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(padding: const EdgeInsets.all(16), children: _content(context, state)),
              ),
            ),
    ),
  );

  List<Widget> _content(BuildContext context, ProductState state) {
    final theme = Theme.of(context);
    final product = state.product;
    final muted = theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final lastPurchase = state.lastPurchase;
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(productId: productId, hasImage: product?.hasImage ?? false, size: 96),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.name!, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                if (product != null) ...[
                  Text(unitPriceLabel(product.priceIncl, product.uom), style: theme.textTheme.headlineSmall),
                  Text(product.category, style: muted),
                  if (product.barcode case final barcode?) Text('Code-barres $barcode', style: muted),
                ] else
                  Text("Ce produit n'est plus au catalogue.", style: muted),
                if (lastPurchase != null) Text('Dernier achat le ${dayLabel(lastPurchase)}', style: muted),
              ],
            ),
          ),
        ],
      ),
      if (product != null) ...[
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            icon: const Icon(Icons.playlist_add),
            label: const Text('Ajouter à la liste'),
            onPressed: () => addProductToShoppingList(
              context,
              productId: product.id,
              name: product.name,
              uom: product.uom,
              quantity: quantityStep(product.uom) == 1 ? 1 : 0.5,
            ),
          ),
        ),
      ],
      const SizedBox(height: 24),
      Text('Évolution du prix', style: theme.textTheme.titleMedium),
      const SizedBox(height: 8),
      if (state.history.isEmpty)
        Text("Pas encore d'historique de prix pour ce produit.", style: muted)
      else ...[
        PriceChart(changes: state.history, until: now(), uom: state.uom),
        const SizedBox(height: 8),
        // The same data as a list, most recent first.
        for (final (index, change) in state.history.reversed.indexed)
          _PriceChangeTile(
            change: change,
            previous: index + 1 < state.history.length ? state.history.reversed.elementAt(index + 1) : null,
            uom: state.uom,
          ),
        const SizedBox(height: 8),
        Text(
          'Prix payés lors de vos achats, complétés par les prix du catalogue relevés par cette '
          'application depuis son installation.',
          style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    ];
  }
}

class _PriceChangeTile extends StatelessWidget {
  const _PriceChangeTile({required this.change, required this.previous, required this.uom});

  final PriceChange change;
  final PriceChange? previous;
  final String uom;

  @override
  Widget build(BuildContext context) {
    final delta = previous == null ? null : change.price - previous!.price;
    final source = change.source == PriceSource.paid ? 'prix payé' : 'prix du catalogue';
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        delta == null
            ? Icons.fiber_manual_record_outlined
            : delta > 0
            ? Icons.arrow_upward
            : Icons.arrow_downward,
        size: 20,
      ),
      title: Text(unitPriceLabel(change.price, uom)),
      subtitle: Text('Depuis le ${dayLabel(change.since)} · $source'),
      trailing: delta == null ? null : Text(priceDeltaLabel(delta)),
    );
  }
}
