import 'dart:convert';
import 'dart:typed_data';

import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with [respond] and records what was sent.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final ResponseBody Function(RequestOptions request) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json; charset=utf-8'],
  },
);

const _session = Session(
  server: CoopServer(name: 'Coop', baseUrl: 'https://coop.example', apiBase: '/coop_app/v1', features: []),
  token: 'tok',
);

(CoopApi, _FakeAdapter) _api(ResponseBody Function(RequestOptions) respond) {
  final adapter = _FakeAdapter(respond);
  return (CoopApi(Dio()..httpClientAdapter = adapter), adapter);
}

void main() {
  group('server address', () {
    test('defaults to https and keeps only the origin', () {
      expect(normalizeServerAddress(' membres.coop.fr '), 'https://membres.coop.fr');
      expect(normalizeServerAddress('https://membres.coop.fr/shop?x=1'), 'https://membres.coop.fr');
      expect(normalizeServerAddress('http://localhost:8069/'), 'http://localhost:8069');
    });

    test('rejects what is not a web address', () {
      for (final address in ['', 'ftp://coop.fr', 'https://']) {
        expect(() => normalizeServerAddress(address), throwsA(isA<CoopApiException>()), reason: address);
      }
    });
  });

  group('discovery', () {
    test('reads the discovery document of the instance', () async {
      final (api, adapter) = _api(
        (_) => _json({
          'name': 'Le Chaudron',
          'api_version': 1,
          'api_base': '/coop_app/v1',
          'features': ['purchases'],
        }),
      );

      final server = await api.discover('coop.example/shop');

      expect(adapter.requests.single.uri.toString(), 'https://coop.example/.well-known/coop-app.json');
      expect(server.name, 'Le Chaudron');
      expect(server.apiUrl, 'https://coop.example/coop_app/v1');
      expect(server.features, ['purchases']);
    });

    test('refuses another API version, a plain web site or a 404', () async {
      final answers = <ResponseBody Function(RequestOptions)>[
        (_) => _json({'name': 'Coop', 'api_version': 2, 'api_base': '/coop_app/v2', 'features': <String>[]}),
        (_) => ResponseBody.fromString('<html></html>', 200),
        (_) => ResponseBody.fromString('not found', 404),
      ];
      for (final answer in answers) {
        final (api, _) = _api(answer);
        await expectLater(
          api.discover('coop.example'),
          throwsA(isA<CoopApiException>().having((e) => e.code, 'code', CoopApiException.notACoopServer)),
        );
      }
    });

    test('reports an unreachable server as a network failure', () async {
      final (api, _) = _api((request) => throw DioException.connectionError(requestOptions: request, reason: 'down'));
      await expectLater(
        api.discover('coop.example'),
        throwsA(isA<CoopApiException>().having((e) => e.code, 'code', CoopApiException.network)),
      );
    });
  });

  test('login sends the credentials and returns the device token', () async {
    final (api, adapter) = _api((_) => _json({'token': 'abc'}));

    final token = await api.login(_session.server, login: 'alice', password: 'secret', deviceName: 'android');

    expect(token, 'abc');
    expect(adapter.requests.single.uri.path, '/coop_app/v1/login');
    expect(adapter.requests.single.data, {'login': 'alice', 'password': 'secret', 'device_name': 'android'});
  });

  test('the server error code is surfaced', () async {
    final (api, _) = _api(
      (_) => _json({
        'error': {'code': 'INVALID_CREDENTIALS', 'message': 'Wrong login or password.'},
      }, 401),
    );
    await expectLater(
      api.login(_session.server, login: 'alice', password: 'bad', deviceName: 'web'),
      throwsA(isA<CoopApiException>().having((e) => e.code, 'code', 'INVALID_CREDENTIALS')),
    );
  });

  test('an error without a body is reported by its status', () async {
    final (api, _) = _api((_) => ResponseBody.fromString('Bad gateway', 502));
    await expectLater(api.me(_session), throwsA(isA<CoopApiException>().having((e) => e.code, 'code', 'HTTP_502')));
  });

  test('authenticated calls send the bearer token', () async {
    final (api, adapter) = _api(
      (_) => _json({'name': 'Alice', 'member_number': '42', 'purchase_history_consent': true}),
    );

    final member = await api.me(_session);

    expect(adapter.requests.single.headers['Authorization'], 'Bearer tok');
    expect((member.name, member.memberNumber, member.purchaseHistoryConsent), ('Alice', '42', true));
  });

  test('purchases are parsed, with UTC dates and the cursor passed on', () async {
    final (api, adapter) = _api(
      (_) => _json({
        'lines': [
          {
            'id': 7,
            'order_id': 3,
            'date': '2026-05-14 17:30:00',
            'product_id': 2,
            'product_name': 'Café moulu 250g',
            'barcode': null,
            'uom': 'kg',
            'qty': 1,
            'total_incl': 4.5,
          },
        ],
        'next_cursor': 'next',
        'has_more': true,
      }),
    );

    final page = await api.purchases(_session, cursor: 'previous');

    expect(adapter.requests.single.uri.queryParameters, {'cursor': 'previous'});
    expect((page.nextCursor, page.hasMore), ('next', true));
    final line = page.lines.single;
    expect(line.date, DateTime.utc(2026, 5, 14, 17, 30));
    expect((line.id, line.orderId, line.productId, line.qty, line.totalIncl), (7, 3, 2, 1.0, 4.5));
    expect((line.productName, line.barcode, line.uom), ('Café moulu 250g', null, 'kg'));
  });

  test('catalogue pages separate the products to store from those to remove', () async {
    final (api, adapter) = _api(
      (_) => _json({
        'products': [
          {
            'id': 2,
            'name': 'Café moulu 250g',
            'barcode': '376',
            'category': 'Épicerie',
            'uom': 'Units',
            'price_incl': 4.9,
            'has_image': true,
            'active': true,
          },
          {
            'id': 3,
            'name': 'Ancien',
            'barcode': null,
            'category': 'All',
            'uom': 'kg',
            'price_incl': 1,
            'active': false,
          },
        ],
        'next_cursor': 'next',
        'has_more': false,
      }),
    );

    final page = await api.products(_session, cursor: 'previous');

    expect(adapter.requests.single.uri.path, '/coop_app/v1/products');
    expect(adapter.requests.single.uri.queryParameters, {'cursor': 'previous'});
    expect(adapter.requests.single.headers['Authorization'], 'Bearer tok');
    final product = page.products.single;
    expect((product.id, product.name, product.barcode, product.category), (2, 'Café moulu 250g', '376', 'Épicerie'));
    expect((product.uom, product.priceIncl, product.hasImage), ('Units', 4.9, true));
    expect(page.removedIds, [3]);
    expect((page.nextCursor, page.hasMore), ('next', false));
  });

  test('a product picture is addressed under the API and fetched with the token', () {
    final api = CoopApi(Dio());
    expect(api.productImageUrl(_session, 7), 'https://coop.example/coop_app/v1/products/7/image');
    expect(api.authHeaders(_session), {'Authorization': 'Bearer tok'});
  });

  test('the first purchases call sends no cursor', () async {
    final (api, adapter) = _api((_) => _json({'lines': <Object>[], 'next_cursor': null, 'has_more': false}));
    await api.purchases(_session);
    expect(adapter.requests.single.uri.queryParameters, isEmpty);
  });
}
