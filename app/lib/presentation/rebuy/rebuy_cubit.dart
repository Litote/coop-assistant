import 'dart:async';

import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/data/repositories/purchase_repository.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/domain/model/purchase_line.dart';
import 'package:coop_assistant/domain/suggestions/rebuy_suggestions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RebuyState {
  const RebuyState({
    this.consent,
    this.suggestions = const [],
    this.hasHistory = false,
    this.busy = true,
    this.errorCode,
  });

  /// Whether the member enabled the purchase history; `null` while unknown.
  final bool? consent;
  final List<RebuySuggestion> suggestions;

  /// Whether any purchase is cached (distinguishes "nothing due" from "no data").
  final bool hasHistory;

  /// A server call is in progress.
  final bool busy;

  /// Code of the last failed call, if any (see `CoopApiException`).
  final String? errorCode;

  RebuyState copyWith({
    bool? consent,
    List<RebuySuggestion>? suggestions,
    bool? hasHistory,
    bool? busy,
    String? Function()? errorCode,
  }) => RebuyState(
    consent: consent ?? this.consent,
    suggestions: suggestions ?? this.suggestions,
    hasHistory: hasHistory ?? this.hasHistory,
    busy: busy ?? this.busy,
    errorCode: errorCode == null ? this.errorCode : errorCode(),
  );
}

/// The "buy again" screen: syncs the purchase history and derives the
/// suggestions from the local cache, so they stay available offline.
class RebuyCubit extends Cubit<RebuyState> {
  RebuyCubit({
    required Session session,
    required CoopApi api,
    required PurchaseRepository purchases,
    required Future<void> Function() onUnauthorized,
    DateTime Function() now = DateTime.now,
  }) : _session = session,
       _api = api,
       _purchases = purchases,
       _onUnauthorized = onUnauthorized,
       _now = now,
       super(const RebuyState()) {
    _linesSubscription = _purchases.watchLines().listen((lines) {
      _lines = lines;
      _publish();
    });
    _hiddenSubscription = _purchases.watchHiddenProductIds().listen((hidden) {
      _hidden = hidden;
      _publish();
    });
  }

  final Session _session;
  final CoopApi _api;
  final PurchaseRepository _purchases;
  final Future<void> Function() _onUnauthorized;
  final DateTime Function() _now;

  late final StreamSubscription<List<PurchaseLine>> _linesSubscription;
  late final StreamSubscription<Set<int>> _hiddenSubscription;
  List<PurchaseLine> _lines = const [];
  Set<int> _hidden = const {};

  /// Checks the consent, then syncs the history when it is enabled.
  Future<void> refresh() => _run(() async {
    final member = await _api.me(_session);
    emit(state.copyWith(consent: member.purchaseHistoryConsent));
    if (member.purchaseHistoryConsent) {
      await _purchases.sync(_session);
    } else {
      await _purchases.clear();
    }
  });

  Future<void> enablePurchaseHistory() => _run(() async {
    await _api.setPurchaseHistoryConsent(_session, enabled: true);
    emit(state.copyWith(consent: true));
    await _purchases.sync(_session);
  });

  Future<void> hide(int productId) => _purchases.hideProduct(productId);

  Future<void> _run(Future<void> Function() action) async {
    emit(state.copyWith(busy: true, errorCode: () => null));
    try {
      await action();
      emit(state.copyWith(busy: false));
    } on CoopApiException catch (e) {
      if (e.code == CoopApiException.unauthorized) {
        await _onUnauthorized();
        return;
      }
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          busy: false,
          consent: e.code == CoopApiException.consentRequired ? false : null,
          errorCode: () => e.code == CoopApiException.consentRequired ? null : e.code,
        ),
      );
    }
  }

  void _publish() {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        hasHistory: _lines.isNotEmpty,
        suggestions: rebuySuggestions(_lines, today: _now(), hiddenProductIds: _hidden),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _linesSubscription.cancel();
    await _hiddenSubscription.cancel();
    return super.close();
  }
}
