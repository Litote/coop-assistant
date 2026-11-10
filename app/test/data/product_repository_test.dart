import 'package:coop_assistant/data/local/app_database.dart';
import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/data/repositories/product_repository.dart';
import 'package:coop_assistant/data/repositories/purchase_repository.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/domain/model/product.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements CoopApi {}

const _session = Session(
  server: CoopServer(name: 'Coop', baseUrl: 'https://coop.example', apiBase: '/coop_app/v1', features: []),
  token: 'tok',
);

Product _product(int id, String name, {double price = 4.5}) => Product(
  id: id,
  name: name,
  barcode: '376$id',
  category: 'Épicerie',
  uom: 'Units',
  priceIncl: price,
  hasImage: id == 2,
);

void main() {
  late AppDatabase db;
  late _MockApi api;
  late ProductRepository repository;
  var now = DateTime(2026, 11, 1, 9);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = _MockApi();
    now = DateTime(2026, 11, 1, 9);
    repository = ProductRepository(db, api, now: () => now);
  });

  tearDown(() => db.close());

  void answer(
    String? cursor, {
    List<Product> products = const [],
    List<int> removed = const [],
    String? next,
    bool more = false,
  }) => when(
    () => api.products(_session, cursor: cursor),
  ).thenAnswer((_) async => ProductPage(products: products, removedIds: removed, nextCursor: next, hasMore: more));

  Future<List<(DateTime, double)>> prices(int productId) async => [
    for (final price in await repository.watchCataloguePrices(productId).first) (price.recordedAt, price.price),
  ];

  test('sync follows the pages and lists the catalogue by name', () async {
    answer(null, products: [_product(1, 'pâtes'), _product(2, 'Café')], next: 'c1', more: true);
    answer('c1', products: [_product(3, 'Œufs')], next: 'c2');

    await repository.sync(_session);

    final products = await repository.watchProducts().first;
    expect(products.map((product) => product.name), ['Café', 'pâtes', 'Œufs']);
    expect(products.map((product) => product.hasImage), [true, false, false]);
    final coffee = products.first;
    expect(
      (coffee.id, coffee.barcode, coffee.category, coffee.uom, coffee.priceIncl),
      (2, '3762', 'Épicerie', 'Units', 4.5),
    );
  });

  test('the next sync resumes from the cursor, updates and removes products', () async {
    answer(null, products: [_product(1, 'Café'), _product(2, 'Pâtes')], next: 'c1');
    await repository.sync(_session);
    answer('c1', products: [_product(1, 'Café moulu')], removed: [2, 99], next: 'c2');

    await repository.sync(_session);

    expect((await repository.watchProducts().first).map((product) => product.name), ['Café moulu']);
    expect((await repository.watchProduct(1).first)?.name, 'Café moulu');
    expect(await repository.watchProduct(2).first, isNull);
  });

  test('a price point is recorded on first sight and on each price change only', () async {
    answer(null, products: [_product(1, 'Café')], next: 'c1');
    await repository.sync(_session);

    now = DateTime(2026, 11, 8, 9);
    answer('c1', products: [_product(1, 'Café renommé')], next: 'c2');
    await repository.sync(_session);

    now = DateTime(2026, 11, 15, 9);
    answer('c2', products: [_product(1, 'Café renommé', price: 4.9)], next: 'c3');
    await repository.sync(_session);

    expect(await prices(1), [(DateTime(2026, 11, 1, 9), 4.5), (DateTime(2026, 11, 15, 9), 4.9)]);
  });

  test('clear drops the catalogue and its cursor, not the purchases cursor', () async {
    answer(null, products: [_product(1, 'Café')], next: 'c1');
    await repository.sync(_session);
    when(
      () => api.purchases(_session),
    ).thenAnswer((_) async => const PurchasePage(lines: [], nextCursor: 'p1', hasMore: false));
    when(
      () => api.purchases(_session, cursor: 'p1'),
    ).thenAnswer((_) async => const PurchasePage(lines: [], nextCursor: 'p1', hasMore: false));
    final purchases = PurchaseRepository(db, api);
    await purchases.sync(_session);

    await repository.clear();

    expect(await repository.watchProducts().first, isEmpty);
    expect(await prices(1), isEmpty);
    await repository.sync(_session);
    verify(() => api.products(_session)).called(2);
    await purchases.sync(_session);
    verify(() => api.purchases(_session, cursor: 'p1')).called(1);
  });

  test('a database created by the first version is upgraded in place', () async {
    final file = NativeDatabase.memory(
      setup: (raw) => raw
        ..execute('CREATE TABLE sync_cursors (feed TEXT NOT NULL PRIMARY KEY, cursor TEXT NOT NULL)')
        ..execute("INSERT INTO sync_cursors VALUES ('purchases', 'p1')")
        ..execute('PRAGMA user_version = 1'),
    );
    final upgraded = AppDatabase(file);
    addTearDown(upgraded.close);
    final upgradedRepository = ProductRepository(upgraded, api);
    answer(null, products: [_product(1, 'Café')], next: 'c1');

    await upgradedRepository.sync(_session);

    expect(await upgradedRepository.watchProducts().first, hasLength(1));
    expect((await upgraded.select(upgraded.syncCursors).get()).map((row) => row.feed), ['purchases', 'products']);
  });
}
