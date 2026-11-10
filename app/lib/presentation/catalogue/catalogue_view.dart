import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:coop_assistant/presentation/catalogue/catalogue_cubit.dart';
import 'package:coop_assistant/presentation/common/messages.dart';
import 'package:coop_assistant/presentation/common/product_image.dart';
import 'package:coop_assistant/presentation/shopping/add_to_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The shop's catalogue, searchable offline.
class CatalogueView extends StatelessWidget {
  const CatalogueView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogueCubit, CatalogueState>(
    builder: (context, state) {
      final cubit = context.read<CatalogueCubit>();
      final products = state.visibleProducts;
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              if (state.busy) const LinearProgressIndicator(),
              if (state.errorCode case final code?)
                MaterialBanner(
                  content: Text(errorMessage(code)),
                  actions: [TextButton(onPressed: cubit.refresh, child: const Text('Réessayer'))],
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: cubit.search,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: 'Rechercher un produit',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (state.categories.length > 1)
                      PopupMenuButton<String?>(
                        tooltip: 'Filtrer par catégorie',
                        icon: Icon(state.category == null ? Icons.filter_list : Icons.filter_list_alt),
                        onSelected: cubit.selectCategory,
                        itemBuilder: (context) => [
                          const PopupMenuItem(child: Text('Toutes les catégories')),
                          for (final category in state.categories)
                            CheckedPopupMenuItem(
                              value: category,
                              checked: category == state.category,
                              child: Text(category),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              if (state.category case final category?)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InputChip(label: Text(category), onDeleted: () => cubit.selectCategory(null)),
                  ),
                ),
              Expanded(
                child: products.isEmpty
                    ? _empty(state)
                    : RefreshIndicator(
                        onRefresh: cubit.refresh,
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ListTile(
                              leading: ProductImage(productId: product.id, hasImage: product.hasImage, size: 48),
                              title: Text(product.name),
                              subtitle: Text(product.category),
                              contentPadding: const EdgeInsets.only(left: 16, right: 4),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    unitPriceLabel(product.priceIncl, product.uom),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  IconButton(
                                    tooltip: 'Ajouter ${product.name} à la liste',
                                    icon: const Icon(Icons.playlist_add),
                                    onPressed: () => addProductToShoppingList(
                                      context,
                                      productId: product.id,
                                      name: product.name,
                                      uom: product.uom,
                                      quantity: quantityStep(product.uom) == 1 ? 1 : 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => context.push('/products/${product.id}'),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _empty(CatalogueState state) {
    if (state.products.isNotEmpty) {
      return const Center(child: Text('Aucun produit ne correspond à votre recherche.'));
    }
    return state.busy
        ? const SizedBox.shrink()
        : const Center(child: Text("Le catalogue n'a pas encore pu être chargé."));
  }
}
