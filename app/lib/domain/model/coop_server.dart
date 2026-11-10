/// A cooperative's Odoo instance, as described by its discovery document.
class CoopServer {
  const CoopServer({required this.name, required this.baseUrl, required this.apiBase, required this.features});

  factory CoopServer.fromJson(Map<String, dynamic> json) => CoopServer(
    name: json['name'] as String,
    baseUrl: json['base_url'] as String,
    apiBase: json['api_base'] as String,
    features: (json['features'] as List<dynamic>).cast<String>(),
  );

  final String name;

  /// Origin of the instance, without trailing slash.
  final String baseUrl;

  /// Path prefix of the API on that origin.
  final String apiBase;
  final List<String> features;

  String get apiUrl => '$baseUrl$apiBase';

  Map<String, dynamic> toJson() => {'name': name, 'base_url': baseUrl, 'api_base': apiBase, 'features': features};
}

/// A server and the device token that authenticates the member on it.
class Session {
  const Session({required this.server, required this.token});

  final CoopServer server;
  final String token;
}

/// The connected member.
class Member {
  const Member({required this.name, required this.purchaseHistoryConsent, this.memberNumber});

  final String name;
  final String? memberNumber;
  final bool purchaseHistoryConsent;
}
