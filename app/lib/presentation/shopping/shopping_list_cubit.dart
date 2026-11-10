import 'dart:async';

import 'package:coop_assistant/data/repositories/product_repository.dart';
import 'package:coop_assistant/data/repositories/shopping_list_repository.dart';
import 'package:coop_assistant/domain/model/product.dart';
import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The shopping list tab: the member's lines, priced from the cached catalogue.
class ShoppingListCubit extends Cubit<ShoppingListView> {
  ShoppingListCubit({required ShoppingListRepository shoppingList, required ProductRepository products})
    : _shoppingList = shoppingList,
      super(ShoppingListView.empty) {
    _subscriptions = [
      shoppingList.watchItems().listen((items) {
        _items = items;
        _publish();
      }),
      products.watchProducts().listen((catalogue) {
        _catalogue = catalogue;
        _publish();
      }),
    ];
  }

  final ShoppingListRepository _shoppingList;
  late final List<StreamSubscription<Object?>> _subscriptions;
  List<ShoppingItem> _items = const [];
  List<Product> _catalogue = const [];

  Future<void> addFreeLine(String text) => _shoppingList.addFreeLine(text);

  Future<void> setChecked(ShoppingEntry entry, {required bool checked}) =>
      _shoppingList.setChecked(entry.item.id, checked: checked);

  Future<void> increase(ShoppingEntry entry) =>
      _shoppingList.setQuantity(entry.item.id, steppedQuantity(entry.item.quantity, entry.uom, up: true));

  /// One step less; a line already at its smallest quantity is removed.
  Future<void> decreaseOrRemove(ShoppingEntry entry) => entry.item.quantity <= entry.step
      ? _shoppingList.remove(entry.item.id)
      : _shoppingList.setQuantity(entry.item.id, steppedQuantity(entry.item.quantity, entry.uom, up: false));

  Future<void> emptyBasket() => _shoppingList.removeChecked();

  void _publish() {
    if (!isClosed) {
      emit(shoppingListView(_items, _catalogue));
    }
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
