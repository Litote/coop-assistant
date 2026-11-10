import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Cache of the member's purchase lines, keyed by the server's line id.
@DataClassName('PurchaseLineRow')
class PurchaseLines extends Table {
  IntColumn get id => integer()();
  IntColumn get orderId => integer()();
  DateTimeColumn get date => dateTime()();
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get uom => text()();
  RealColumn get qty => real()();
  RealColumn get totalIncl => real()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Opaque server cursors, one per synced feed.
class SyncCursors extends Table {
  TextColumn get feed => text()();
  TextColumn get cursor => text()();

  @override
  Set<Column<Object>> get primaryKey => {feed};
}

/// Products the member asked not to be suggested again.
class HiddenProducts extends Table {
  IntColumn get productId => integer()();

  @override
  Set<Column<Object>> get primaryKey => {productId};
}

/// Cache of the shop catalogue, keyed by the server's product id.
@DataClassName('ProductRow')
class Products extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get category => text()();
  TextColumn get uom => text()();
  RealColumn get priceIncl => real()();
  BoolColumn get hasImage => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Catalogue prices observed by this device: one row each time a sync brings
/// a price different from the last one known.
@DataClassName('CataloguePriceRow')
class CataloguePrices extends Table {
  IntColumn get productId => integer()();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get price => real()();

  @override
  Set<Column<Object>> get primaryKey => {productId, recordedAt};
}

/// The member's shopping list. It never leaves the device.
@DataClassName('ShoppingItemRow')
class ShoppingItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().nullable()();
  TextColumn get label => text()();
  RealColumn get quantity => real()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [PurchaseLines, SyncCursors, HiddenProducts, Products, CataloguePrices, ShoppingItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The on-device database (IndexedDB/OPFS on the web).
  factory AppDatabase.onDevice() => AppDatabase(
    driftDatabase(
      name: 'coop_assistant',
      web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.dart.js')),
    ),
  );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(products);
        await migrator.createTable(cataloguePrices);
      }
      if (from < 3) {
        await migrator.createTable(shoppingItems);
      }
    },
  );
}
