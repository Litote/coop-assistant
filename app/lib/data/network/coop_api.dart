import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/domain/model/product.dart';
import 'package:coop_assistant/domain/model/purchase_line.dart';
import 'package:dio/dio.dart';

/// Version of the API contract this app speaks (see `docs/api.md`).
const int kSupportedApiVersion = 1;

/// A failed API call. [code] is the server's error code, or one of the
/// client-side codes below.
class CoopApiException implements Exception {
  const CoopApiException(this.code, [this.message = '']);

  /// The server could not be reached.
  static const String network = 'NETWORK';

  /// The address does not host a compatible coop-assistant module.
  static const String notACoopServer = 'NOT_A_COOP_SERVER';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String consentRequired = 'CONSENT_REQUIRED';

  final String code;
  final String message;

  @override
  String toString() => 'CoopApiException($code, $message)';
}

/// One page of the member's purchase lines.
class PurchasePage {
  const PurchasePage({required this.lines, required this.hasMore, this.nextCursor});

  final List<PurchaseLine> lines;
  final String? nextCursor;
  final bool hasMore;
}

/// One page of catalogue changes: [products] to store, [removedIds] to drop.
class ProductPage {
  const ProductPage({required this.products, required this.removedIds, required this.hasMore, this.nextCursor});

  final List<Product> products;
  final List<int> removedIds;
  final String? nextCursor;
  final bool hasMore;
}

/// Client of the `coop_shopping_api` Odoo module.
class CoopApi {
  CoopApi(this._dio);

  final Dio _dio;

  /// Reads the discovery document of the instance at [address] (scheme
  /// optional, `https` by default).
  Future<CoopServer> discover(String address) async {
    final baseUrl = normalizeServerAddress(address);
    final Object? body;
    try {
      body = (await _dio.get<Object?>('$baseUrl/.well-known/coop-app.json')).data;
    } on DioException catch (e) {
      throw e.response == null
          ? const CoopApiException(CoopApiException.network)
          : const CoopApiException(CoopApiException.notACoopServer);
    }
    if (body is! Map<String, dynamic> ||
        body['api_version'] != kSupportedApiVersion ||
        body['api_base'] is! String ||
        body['name'] is! String) {
      throw const CoopApiException(CoopApiException.notACoopServer);
    }
    final features = body['features'];
    return CoopServer(
      name: body['name'] as String,
      baseUrl: baseUrl,
      apiBase: body['api_base'] as String,
      features: features is List ? features.whereType<String>().toList() : const [],
    );
  }

  Future<String> login(
    CoopServer server, {
    required String login,
    required String password,
    required String deviceName,
  }) async {
    final body = await _call(
      () => _dio.post<Object?>(
        '${server.apiUrl}/login',
        data: {'login': login, 'password': password, 'device_name': deviceName},
      ),
    );
    return body['token'] as String;
  }

  Future<void> logout(Session session) =>
      _call(() => _dio.post<Object?>('${session.server.apiUrl}/logout', options: _auth(session)));

  Future<Member> me(Session session) async =>
      _member(await _call(() => _dio.get<Object?>('${session.server.apiUrl}/me', options: _auth(session))));

  Future<Member> setPurchaseHistoryConsent(Session session, {required bool enabled}) async => _member(
    await _call(
      () => _dio.post<Object?>(
        '${session.server.apiUrl}/me/consent',
        data: {'purchase_history': enabled},
        options: _auth(session),
      ),
    ),
  );

  Future<PurchasePage> purchases(Session session, {String? cursor}) async {
    final body = await _call(
      () => _dio.get<Object?>(
        '${session.server.apiUrl}/purchases',
        queryParameters: {'cursor': ?cursor},
        options: _auth(session),
      ),
    );
    return PurchasePage(
      lines: [for (final line in body['lines'] as List<dynamic>) _line(line as Map<String, dynamic>)],
      nextCursor: body['next_cursor'] as String?,
      hasMore: body['has_more'] as bool,
    );
  }

  Future<ProductPage> products(Session session, {String? cursor}) async {
    final body = await _call(
      () => _dio.get<Object?>(
        '${session.server.apiUrl}/products',
        queryParameters: {'cursor': ?cursor},
        options: _auth(session),
      ),
    );
    final items = (body['products'] as List<dynamic>).cast<Map<String, dynamic>>();
    return ProductPage(
      products: [
        for (final json in items)
          if (json['active'] as bool)
            Product(
              id: json['id'] as int,
              name: json['name'] as String,
              barcode: json['barcode'] as String?,
              category: json['category'] as String? ?? '',
              uom: json['uom'] as String,
              priceIncl: (json['price_incl'] as num).toDouble(),
              // Absent on a module older than the pictures.
              hasImage: json['has_image'] as bool? ?? false,
            ),
      ],
      removedIds: [
        for (final json in items)
          if (!(json['active'] as bool)) json['id'] as int,
      ],
      nextCursor: body['next_cursor'] as String?,
      hasMore: body['has_more'] as bool,
    );
  }

  /// Address of a product's picture; fetch it with [authHeaders].
  String productImageUrl(Session session, int productId) => '${session.server.apiUrl}/products/$productId/image';

  Map<String, String> authHeaders(Session session) => {'Authorization': 'Bearer ${session.token}'};

  Options _auth(Session session) => Options(headers: authHeaders(session));

  Future<Map<String, dynamic>> _call(Future<Response<Object?>> Function() request) async {
    try {
      final body = (await request()).data;
      return body is Map<String, dynamic> ? body : const {};
    } on DioException catch (e) {
      final body = e.response?.data;
      final error = body is Map<String, dynamic> ? body['error'] : null;
      if (error is Map<String, dynamic> && error['code'] is String) {
        throw CoopApiException(error['code'] as String, '${error['message'] ?? ''}');
      }
      throw CoopApiException(e.response == null ? CoopApiException.network : 'HTTP_${e.response!.statusCode}');
    }
  }

  Member _member(Map<String, dynamic> body) => Member(
    name: body['name'] as String,
    memberNumber: body['member_number'] as String?,
    purchaseHistoryConsent: body['purchase_history_consent'] as bool,
  );

  PurchaseLine _line(Map<String, dynamic> json) => PurchaseLine(
    id: json['id'] as int,
    orderId: json['order_id'] as int,
    // Odoo serves UTC date-times without a zone marker.
    date: DateTime.parse('${(json['date'] as String).replaceFirst(' ', 'T')}Z'),
    productId: json['product_id'] as int,
    productName: json['product_name'] as String,
    barcode: json['barcode'] as String?,
    uom: json['uom'] as String,
    qty: (json['qty'] as num).toDouble(),
    totalIncl: (json['total_incl'] as num).toDouble(),
  );
}

/// Origin of the instance the member typed: `https` unless a scheme is given,
/// no path, no trailing slash.
String normalizeServerAddress(String address) {
  final trimmed = address.trim();
  final uri = Uri.tryParse(trimmed.contains('://') ? trimmed : 'https://$trimmed');
  if (uri == null || uri.host.isEmpty || (uri.scheme != 'https' && uri.scheme != 'http')) {
    throw const CoopApiException(CoopApiException.notACoopServer);
  }
  return uri.origin;
}
