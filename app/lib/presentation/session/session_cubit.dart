import 'package:coop_assistant/data/auth/session_store.dart';
import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SessionState {
  const SessionState();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

/// No cooperative chosen yet.
class SessionNoServer extends SessionState {
  const SessionNoServer();
}

class SessionLoggedOut extends SessionState {
  const SessionLoggedOut(this.server);

  final CoopServer server;
}

class SessionLoggedIn extends SessionState {
  const SessionLoggedIn(this.session);

  final Session session;
}

/// Which cooperative the app talks to, and as whom. Failed calls throw
/// [CoopApiException] for the calling screen to show.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required CoopApi api,
    required SessionStore store,
    required Future<void> Function() clearLocalData,
    required String deviceName,
  }) : _api = api,
       _store = store,
       _clearLocalData = clearLocalData,
       _deviceName = deviceName,
       super(const SessionLoading());

  final CoopApi _api;
  final SessionStore _store;

  /// Drops everything cached for the member and their cooperative.
  final Future<void> Function() _clearLocalData;
  final String _deviceName;

  Future<void> restore() async {
    final server = await _store.readServer();
    final token = await _store.readToken();
    emit(switch ((server, token)) {
      (null, _) => const SessionNoServer(),
      (final server?, null) => SessionLoggedOut(server),
      (final server?, final token?) => SessionLoggedIn(Session(server: server, token: token)),
    });
  }

  Future<void> chooseServer(String address) async {
    final server = await _api.discover(address);
    await _store.writeServer(server);
    emit(SessionLoggedOut(server));
  }

  Future<void> forgetServer() async {
    await _store.writeServer(null);
    emit(const SessionNoServer());
  }

  Future<void> login({required String login, required String password}) async {
    final current = state;
    if (current is! SessionLoggedOut) {
      return;
    }
    final token = await _api.login(current.server, login: login, password: password, deviceName: _deviceName);
    await _store.writeToken(token);
    emit(SessionLoggedIn(Session(server: current.server, token: token)));
  }

  /// Revokes the device token (best effort when offline) and drops the
  /// member's cached data.
  Future<void> logout() async {
    final current = state;
    if (current is! SessionLoggedIn) {
      return;
    }
    try {
      await _api.logout(current.session);
    } on CoopApiException {
      // The token stays valid server-side until it expires; nothing local is kept.
    }
    await _signOutLocally(current.session.server);
  }

  /// The server refused the token (revoked or expired).
  Future<void> expire() async {
    final current = state;
    if (current is SessionLoggedIn) {
      await _signOutLocally(current.session.server);
    }
  }

  Future<void> _signOutLocally(CoopServer server) async {
    await _store.writeToken(null);
    await _clearLocalData();
    emit(SessionLoggedOut(server));
  }
}
