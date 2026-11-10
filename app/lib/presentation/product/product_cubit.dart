import 'dart:async';

import 'package:coop_assistant/data/repositories/product_repository.dart';
import 'package:coop_assistant/data/repositories/purchase_repository.dart';
import 'package:coop_assistant/domain/model/product.dart';
import 'package:coop_assistant/domain/model/purchase_line.dart';
import 'package:coop_assistant/domain/prices/price_history.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductState {
  const ProductState({this.product, this.purchases = const [], this.history = const [], this.loaded = false});

  /// The catalogue entry; `null` for a product bought in the past that is no
  /// longer (or not yet) in the cached catalogue.
  final Product? product;

  /// The member's own purchases of the product.
  final List<PurchaseLine> purchases;
  final List<PriceChange> history;
  final bool loaded;

  PurchaseLine? get _latestPurchase =>
      purchases.isEmpty ? null : purchases.reduce((a, b) => b.date.isAfter(a.date) ? b : a);

  String? get name => product?.name ?? _latestPurchase?.productName;

  String get uom => product?.uom ?? _latestPurchase?.uom ?? '';

  /// Day of the last time the member bought the product (returns aside).
  DateTime? get lastPurchase {
    final bought = purchases.where((line) => line.qty > 0).map((line) => line.date);
    return bought.isEmpty ? null : bought.reduce((a, b) => b.isAfter(a) ? b : a);
  }
}

/// One product: its catalogue entry and its price over time, from the cache.
class ProductCubit extends Cubit<ProductState> {
  ProductCubit({required int productId, required ProductRepository products, required PurchaseRepository purchases})
    : super(const ProductState()) {
    _subscriptions = [
      products.watchProduct(productId).listen((product) {
        _product = product;
        _productLoaded = true;
        _publish();
      }),
      purchases.watchLinesOfProduct(productId).listen((lines) {
        _lines = lines;
        _publish();
      }),
      products.watchCataloguePrices(productId).listen((prices) {
        _prices = prices;
        _publish();
      }),
    ];
  }

  late final List<StreamSubscription<Object?>> _subscriptions;
  Product? _product;
  var _productLoaded = false;
  List<PurchaseLine>? _lines;
  List<CataloguePrice>? _prices;

  void _publish() {
    final lines = _lines;
    final prices = _prices;
    if (isClosed || !_productLoaded || lines == null || prices == null) {
      return;
    }
    emit(
      ProductState(
        product: _product,
        purchases: lines,
        history: priceHistory(purchases: lines, cataloguePrices: prices),
        loaded: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
