import 'dart:async';

import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/data/repositories/product_repository.dart';
import 'package:coop_assistant/domain/catalogue/product_search.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/domain/model/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CatalogueState {
  const CatalogueState({this.products = const [], this.query = '', this.category, this.busy = true, this.errorCode});

  /// The whole cached catalogue.
  final List<Product> products;
  final String query;

  /// Category the list is narrowed to, if any.
  final String? category;
  final bool busy;
  final String? errorCode;

  List<String> get categories => {for (final product in products) product.category}.toList()..sort();

  List<Product> get visibleProducts => searchProducts(products, query: query, category: category);

  CatalogueState copyWith({
    List<Product>? products,
    String? query,
    String? Function()? category,
    bool? busy,
    String? Function()? errorCode,
  }) => CatalogueState(
    products: products ?? this.products,
    query: query ?? this.query,
    category: category == null ? this.category : category(),
    busy: busy ?? this.busy,
    errorCode: errorCode == null ? this.errorCode : errorCode(),
  );
}

/// The catalogue tab: syncs the shop's products and searches the local cache.
class CatalogueCubit extends Cubit<CatalogueState> {
  CatalogueCubit({
    required Session session,
    required ProductRepository products,
    required Future<void> Function() onUnauthorized,
  }) : _session = session,
       _products = products,
       _onUnauthorized = onUnauthorized,
       super(const CatalogueState()) {
    _subscription = _products.watchProducts().listen((products) {
      if (!isClosed) {
        // A category that disappeared from the catalogue no longer filters.
        final category = products.any((product) => product.category == state.category) ? state.category : null;
        emit(state.copyWith(products: products, category: () => category));
      }
    });
  }

  final Session _session;
  final ProductRepository _products;
  final Future<void> Function() _onUnauthorized;
  late final StreamSubscription<List<Product>> _subscription;

  Future<void> refresh() async {
    emit(state.copyWith(busy: true, errorCode: () => null));
    try {
      await _products.sync(_session);
      if (!isClosed) {
        emit(state.copyWith(busy: false));
      }
    } on CoopApiException catch (e) {
      if (e.code == CoopApiException.unauthorized) {
        await _onUnauthorized();
      } else if (!isClosed) {
        emit(state.copyWith(busy: false, errorCode: () => e.code));
      }
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  void selectCategory(String? category) => emit(state.copyWith(category: () => category));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
