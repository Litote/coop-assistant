import 'package:coop_assistant/data/local/app_database.dart';
import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/data/repositories/purchase_repository.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/domain/model/purchase_line.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements CoopApi {}

const _session = Session(
  server: CoopServer(name: 'Coop', baseUrl: 'https://coop.example', apiBase: '/coop_app/v1', features: []),
  token: 'tok',
);

PurchaseLine _line(int id, {double qty = 1}) => PurchaseLine(
  id: id,
  orderId: 1,
  date: DateTime.utc(2026, 11, 1, 18),
  productId: 5,
  productName: 'Coffee',
  barcode: '376',
  uom: 'Units',
  qty: qty,
  totalIncl: 4.5 * qty,
);

void main() {
  late AppDatabase db;
  late _MockApi api;
  late PurchaseRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = _MockApi();
    repository = PurchaseRepository(db, api);
  });

  tearDown(() => db.close());

  void answer(String? cursor, PurchasePage page) =>
      when(() => api.purchases(_session, cursor: cursor)).thenAnswer((_) async => page);

  test('sync follows the pages and stores every line', () async {
    answer(null, PurchasePage(lines: [_line(1), _line(2)], nextCursor: 'c1', hasMore: true));
    answer('c1', PurchasePage(lines: [_line(3)], nextCursor: 'c2', hasMore: false));

    await repository.sync(_session);

    final lines = await repository.watchLines().first;
    expect(lines.map((line) => line.id), [1, 2, 3]);
    final stored = lines.first;
    expect(
      (stored.productName, stored.barcode, stored.uom, stored.qty, stored.totalIncl),
      ('Coffee', '376', 'Units', 1, 4.5),
    );
    expect(stored.date.isAtSameMomentAs(DateTime.utc(2026, 11, 1, 18)), isTrue);
  });

  test('the next sync resumes from the stored cursor and upserts served-again lines', () async {
    answer(null, PurchasePage(lines: [_line(1)], nextCursor: 'c1', hasMore: false));
    await repository.sync(_session);
    answer('c1', PurchasePage(lines: [_line(1, qty: 2), _line(2)], nextCursor: 'c2', hasMore: false));

    await repository.sync(_session);

    final lines = await repository.watchLines().first;
    expect({for (final line in lines) line.id: line.qty}, {1: 2.0, 2: 1.0});
    verifyNever(() => api.purchases(_session, cursor: 'c2'));
  });

  test('a sync interrupted between two pages resumes after the last stored page', () async {
    answer(null, PurchasePage(lines: [_line(1)], nextCursor: 'c1', hasMore: true));
    when(() => api.purchases(_session, cursor: 'c1')).thenThrow(const CoopApiException(CoopApiException.network));

    await expectLater(repository.sync(_session), throwsA(isA<CoopApiException>()));
    answer('c1', PurchasePage(lines: [_line(2)], nextCursor: 'c2', hasMore: false));
    await repository.sync(_session);

    expect((await repository.watchLines().first).map((line) => line.id), [1, 2]);
    verify(() => api.purchases(_session)).called(1);
  });

  test('an empty answer keeps the cursor', () async {
    answer(null, PurchasePage(lines: [_line(1)], nextCursor: 'c1', hasMore: false));
    await repository.sync(_session);
    answer('c1', const PurchasePage(lines: [], nextCursor: 'c1', hasMore: false));

    await repository.sync(_session);
    await repository.sync(_session);

    verify(() => api.purchases(_session, cursor: 'c1')).called(2);
  });

  test('hidden products are remembered', () async {
    await repository.hideProduct(5);
    await repository.hideProduct(5);
    expect(await repository.watchHiddenProductIds().first, {5});
  });

  test('clear drops lines, cursor and hidden products', () async {
    answer(null, PurchasePage(lines: [_line(1)], nextCursor: 'c1', hasMore: false));
    await repository.sync(_session);
    await repository.hideProduct(5);

    await repository.clear();

    expect(await repository.watchLines().first, isEmpty);
    expect(await repository.watchHiddenProductIds().first, isEmpty);
    await repository.sync(_session);
    verify(() => api.purchases(_session)).called(2);
  });
}
