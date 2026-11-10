import 'package:coop_assistant/data/local/app_database.dart';
import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/domain/model/product.dart';
import 'package:drift/drift.dart';

/// The cooperative's shop catalogue: synced, read offline, with the price
/// changes this device witnessed.
class ProductRepository {
  ProductRepository(this._db, this._api, {DateTime Function() now = DateTime.now}) : _now = now;

  static const _feed = 'products';

  final AppDatabase _db;
  final CoopApi _api;
  final DateTime Function() _now;

  /// The whole catalogue, by name.
  Stream<List<Product>> watchProducts() =>
      (_db.select(_db.products)..orderBy([(row) => OrderingTerm(expression: row.name.collate(Collate.noCase))]))
          .watch()
          .map((rows) => rows.map(_product).toList());

  Stream<Product?> watchProduct(int id) => (_db.select(
    _db.products,
  )..where((row) => row.id.equals(id))).watchSingleOrNull().map((row) => row == null ? null : _product(row));

  Stream<List<CataloguePrice>> watchCataloguePrices(int productId) =>
      (_db.select(_db.cataloguePrices)..where((row) => row.productId.equals(productId))).watch().map(
        (rows) => [for (final row in rows) CataloguePrice(recordedAt: row.recordedAt, price: row.price)],
      );

  /// Fetches what changed in the catalogue since the last sync. Each page is
  /// stored together with its cursor, so an interrupted sync resumes.
  Future<void> sync(Session session) async {
    var cursor = (await (_db.select(
      _db.syncCursors,
    )..where((row) => row.feed.equals(_feed))).getSingleOrNull())?.cursor;
    var hasMore = true;
    while (hasMore) {
      final page = await _api.products(session, cursor: cursor);
      cursor = page.nextCursor;
      hasMore = page.hasMore;
      await _db.transaction(() => _store(page));
    }
  }

  Future<void> _store(ProductPage page) async {
    final ids = [for (final product in page.products) product.id];
    final knownPrices = {
      for (final row in await (_db.select(_db.products)..where((row) => row.id.isIn(ids))).get()) row.id: row.priceIncl,
    };
    final recordedAt = _now();
    await _db.batch((batch) {
      batch
        ..insertAllOnConflictUpdate(_db.products, [
          for (final product in page.products)
            ProductsCompanion.insert(
              id: Value(product.id),
              name: product.name,
              barcode: Value(product.barcode),
              category: product.category,
              uom: product.uom,
              priceIncl: product.priceIncl,
              hasImage: Value(product.hasImage),
            ),
        ])
        // A price point is recorded when a product appears and whenever its price moves.
        ..insertAllOnConflictUpdate(_db.cataloguePrices, [
          for (final product in page.products)
            if (knownPrices[product.id] != product.priceIncl)
              CataloguePricesCompanion.insert(productId: product.id, recordedAt: recordedAt, price: product.priceIncl),
        ])
        ..deleteWhere(_db.products, (row) => row.id.isIn(page.removedIds));
    });
    if (page.nextCursor case final next?) {
      await _db.into(_db.syncCursors).insertOnConflictUpdate(SyncCursorsCompanion.insert(feed: _feed, cursor: next));
    }
  }

  /// Drops the cached catalogue (logout: another member, maybe another shop).
  Future<void> clear() => _db.transaction(() async {
    await _db.delete(_db.products).go();
    await _db.delete(_db.cataloguePrices).go();
    await (_db.delete(_db.syncCursors)..where((row) => row.feed.equals(_feed))).go();
  });

  Product _product(ProductRow row) => Product(
    id: row.id,
    name: row.name,
    barcode: row.barcode,
    category: row.category,
    uom: row.uom,
    priceIncl: row.priceIncl,
    hasImage: row.hasImage,
  );
}
