import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:coop_assistant/presentation/common/messages.dart';
import 'package:coop_assistant/presentation/shopping/shopping_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The member's shopping list, usable in the shop without network.
class ShoppingListTab extends StatefulWidget {
  const ShoppingListTab({super.key});

  @override
  State<ShoppingListTab> createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab> {
  final _newLine = TextEditingController();

  @override
  void dispose() {
    _newLine.dispose();
    super.dispose();
  }

  Future<void> _addFreeLine() async {
    await context.read<ShoppingListCubit>().addFreeLine(_newLine.text);
    _newLine.clear();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ShoppingListCubit, ShoppingListView>(
    builder: (context, list) {
      final theme = Theme.of(context);
      final cubit = context.read<ShoppingListCubit>();
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _newLine,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _addFreeLine(),
                  decoration: InputDecoration(
                    hintText: 'Ajouter un article',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                      tooltip: "Ajouter l'article",
                      icon: const Icon(Icons.add),
                      onPressed: _addFreeLine,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Votre liste est vide.\nAjoutez des produits depuis le catalogue ou vos suggestions, '
                            'ou saisissez un article ci-dessus.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView(
                        children: [
                          for (final entry in list.toBuy) _EntryTile(entry, key: ValueKey(entry.item.id)),
                          if (list.inBasket.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Dans le panier (${list.inBasket.length})',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ),
                                  TextButton(onPressed: cubit.emptyBasket, child: const Text('Vider le panier')),
                                ],
                              ),
                            ),
                          for (final entry in list.inBasket) _EntryTile(entry, key: ValueKey(entry.item.id)),
                        ],
                      ),
              ),
              if (!list.isEmpty)
                Material(
                  color: theme.colorScheme.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total estimé', style: theme.textTheme.titleSmall),
                              if (list.unpricedCount > 0)
                                Text(
                                  list.unpricedCount == 1
                                      ? 'hors 1 article sans prix'
                                      : 'hors ${list.unpricedCount} articles sans prix',
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        Text(priceLabel(list.estimatedTotal), style: theme.textTheme.titleLarge),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _EntryTile extends StatelessWidget {
  const _EntryTile(this.entry, {super.key});

  final ShoppingEntry entry;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShoppingListCubit>();
    final theme = Theme.of(context);
    final checked = entry.item.checked;
    final atMinimum = entry.item.quantity <= entry.step;
    final quantity = quantityLabel(entry.item.quantity, entry.uom);
    final total = entry.total;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 4, right: 8),
      leading: Checkbox(
        value: checked,
        onChanged: (value) => cubit.setChecked(entry, checked: value ?? false),
        semanticLabel: checked ? 'Remettre ${entry.label} à acheter' : 'Mettre ${entry.label} dans le panier',
      ),
      title: Text(
        entry.label,
        style: checked
            ? TextStyle(decoration: TextDecoration.lineThrough, color: theme.colorScheme.onSurfaceVariant)
            : null,
      ),
      subtitle: total == null ? null : Text(priceLabel(total)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: atMinimum ? 'Retirer de la liste' : 'Diminuer la quantité',
            icon: Icon(atMinimum ? Icons.delete_outline : Icons.remove),
            onPressed: () => cubit.decreaseOrRemove(entry),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 40),
            child: Text(quantity, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          ),
          IconButton(
            tooltip: 'Augmenter la quantité',
            icon: const Icon(Icons.add),
            onPressed: () => cubit.increase(entry),
          ),
        ],
      ),
    );
  }
}
