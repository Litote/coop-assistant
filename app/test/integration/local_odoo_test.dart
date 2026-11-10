// End-to-end check of the data path against a real Odoo with the development
// seed (see the repository README). Skipped unless COOP_ODOO_URL is set:
//
//   COOP_ODOO_URL=http://localhost:8069 flutter test test/integration
import 'dart:io';

import 'package:coop_assistant/data/local/app_database.dart';
import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/data/repositories/product_repository.dart';
import 'package:coop_assistant/data/repositories/purchase_repository.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/domain/suggestions/rebuy_suggestions.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final url = Platform.environment['COOP_ODOO_URL'];

  test(
    'a seeded member syncs their purchases and gets suggestions',
    skip: url == null ? 'COOP_ODOO_URL is not set' : false,
    () async {
      final api = CoopApi(Dio());
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = PurchaseRepository(db, api);

      final server = await api.discover(url!);
      expect(server.features, contains('purchases'));
      await expectLater(
        api.login(server, login: 'chloe@example.org', password: 'nope', deviceName: 'test'),
        throwsA(isA<CoopApiException>().having((e) => e.code, 'code', 'INVALID_CREDENTIALS')),
      );
      final token = await api.login(
        server,
        login: 'chloe@example.org',
        password: 'coop-password-1',
        deviceName: 'integration test',
      );
      final session = Session(server: server, token: token);
      addTearDown(() async {
        // Revoke the token if the test stopped before doing so itself.
        try {
          await api.logout(session);
        } on CoopApiException {
          // Already revoked.
        }
      });
      expect((await api.me(session)).purchaseHistoryConsent, isTrue);

      await repository.sync(session);
      final lines = await repository.watchLines().first;
      await repository.sync(session);
      expect(await repository.watchLines().first, hasLength(lines.length), reason: 'a second sync adds nothing');

      // Chloé's own products only — never another member's (pasta, apples…).
      expect(lines.map((line) => line.productName).toSet(), {
        'Farine T65 1kg',
        'Lentilles vertes (vrac)',
        'Café moulu 250g',
        'Lait demi-écrémé 1L',
      });
      final suggestions = rebuySuggestions(lines, today: DateTime.now());
      for (final s in suggestions) {
        // ignore: avoid_print
        print('${s.status.name}: ${s.productName} (every ${s.usualIntervalDays} d, expected ${s.expectedOn})');
      }
      // She gave milk up three months ago: it must not be suggested.
      expect(suggestions.map((s) => s.productName), isNot(contains('Lait demi-écrémé 1L')));

      // The shop catalogue, with categories and tax-included prices.
      final products = ProductRepository(db, api);
      await products.sync(session);
      final catalogue = await products.watchProducts().first;
      expect(catalogue, hasLength(13));
      final coffee = catalogue.singleWhere((product) => product.name == 'Café moulu 250g');
      expect((coffee.priceIncl, coffee.category, coffee.barcode), (4.9, 'Épicerie', '3760000000017'));
      expect(
        [
          for (final product in catalogue)
            if (product.hasImage) product.name,
        ],
        ['Café moulu 250g'],
      );
      expect(await products.watchCataloguePrices(coffee.id).first, hasLength(1));
      final image = await Dio().get<List<int>>(
        api.productImageUrl(session, coffee.id),
        options: Options(headers: api.authHeaders(session), responseType: ResponseType.bytes),
      );
      expect(image.headers.value('content-type'), startsWith('image/'));

      await api.logout(session);
      await expectLater(
        api.me(session),
        throwsA(isA<CoopApiException>().having((e) => e.code, 'code', CoopApiException.unauthorized)),
      );
    },
  );
}
