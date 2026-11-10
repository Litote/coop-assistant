import 'dart:convert';

import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers the chosen cooperative and the device token across launches.
abstract interface class SessionStore {
  Future<CoopServer?> readServer();

  Future<void> writeServer(CoopServer? server);

  Future<String?> readToken();

  Future<void> writeToken(String? token);
}

class SecureSessionStore implements SessionStore {
  const SecureSessionStore([this._storage = const FlutterSecureStorage()]);

  static const _serverKey = 'coop_server';
  static const _tokenKey = 'device_token';

  final FlutterSecureStorage _storage;

  @override
  Future<CoopServer?> readServer() async {
    final json = await _storage.read(key: _serverKey);
    return json == null ? null : CoopServer.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> writeServer(CoopServer? server) =>
      _storage.write(key: _serverKey, value: server == null ? null : jsonEncode(server.toJson()));

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String? token) => _storage.write(key: _tokenKey, value: token);
}

class InMemorySessionStore implements SessionStore {
  InMemorySessionStore({this.server, this.token});

  CoopServer? server;
  String? token;

  @override
  Future<CoopServer?> readServer() async => server;

  @override
  Future<void> writeServer(CoopServer? server) async => this.server = server;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String? token) async => this.token = token;
}
