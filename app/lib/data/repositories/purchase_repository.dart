import 'package:coop_assistant/data/local/app_database.dart';
import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/domain/model/purchase_line.dart';
import 'package:drift/drift.dart';

/// The member's purchase history: synced from the cooperative, read offline.
class PurchaseRepository {
  PurchaseRepository(this._db, this._api);

  static const _feed = 'purchases';

  final AppDatabase _db;
  final CoopApi _api;

  Stream<List<PurchaseLine>> watchLines() => _db.select(_db.purchaseLines).watch().map(_lines);

  Stream<List<PurchaseLine>> watchLinesOfProduct(int productId) =>
      (_db.select(_db.purchaseLines)..where((row) => row.productId.equals(productId))).watch().map(_lines);

  List<PurchaseLine> _lines(List<PurchaseLineRow> rows) => [
    for (final row in rows)
      PurchaseLine(
        id: row.id,
        orderId: row.orderId,
        date: row.date,
        productId: row.productId,
        productName: row.productName,
        barcode: row.barcode,
        uom: row.uom,
        qty: row.qty,
        totalIncl: row.totalIncl,
      ),
  ];

  Stream<Set<int>> watchHiddenProductIds() =>
      _db.select(_db.hiddenProducts).watch().map((rows) => {for (final row in rows) row.productId});

  /// Fetches what changed since the last sync. Each page is stored together
  /// with its cursor, so an interrupted sync resumes where it stopped.
  Future<void> sync(Session session) async {
    var cursor = (await (_db.select(
      _db.syncCursors,
    )..where((row) => row.feed.equals(_feed))).getSingleOrNull())?.cursor;
    var hasMore = true;
    while (hasMore) {
      final page = await _api.purchases(session, cursor: cursor);
      cursor = page.nextCursor;
      hasMore = page.hasMore;
      await _db.transaction(() async {
        await _db.batch(
          (batch) => batch.insertAllOnConflictUpdate(_db.purchaseLines, [
            for (final line in page.lines)
              PurchaseLinesCompanion.insert(
                id: Value(line.id),
                orderId: line.orderId,
                date: line.date,
                productId: line.productId,
                productName: line.productName,
                barcode: Value(line.barcode),
                uom: line.uom,
                qty: line.qty,
                totalIncl: line.totalIncl,
              ),
          ]),
        );
        if (page.nextCursor case final next?) {
          await _db
              .into(_db.syncCursors)
              .insertOnConflictUpdate(SyncCursorsCompanion.insert(feed: _feed, cursor: next));
        }
      });
    }
  }

  Future<void> hideProduct(int productId) =>
      _db.into(_db.hiddenProducts).insertOnConflictUpdate(HiddenProductsCompanion.insert(productId: Value(productId)));

  /// Drops everything cached for the member (logout, consent withdrawn).
  Future<void> clear() => _db.transaction(() async {
    await _db.delete(_db.purchaseLines).go();
    await (_db.delete(_db.syncCursors)..where((row) => row.feed.equals(_feed))).go();
    await _db.delete(_db.hiddenProducts).go();
  });
}
