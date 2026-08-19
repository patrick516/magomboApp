// lib/providers/live_session_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/live_session.dart';
import '../services/api/live_session_api.dart';

/// Member-facing: polls the backend for whether anyone is currently live.
/// Polling (not push) for now — see conversation notes on why, and revisit
/// once FCM is wired in for the Notifications feature.
class CurrentLiveSessionNotifier extends AsyncNotifier<LiveSession?> {
  Timer? _timer;
  final _api = LiveSessionApi();

  @override
  Future<LiveSession?> build() async {
    ref.onDispose(() => _timer?.cancel());
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => _refresh());
    return _api.getCurrentLiveSession();
  }

  Future<void> _refresh() async {
    try {
      final session = await _api.getCurrentLiveSession();
      state = AsyncData(session);
    } catch (_) {
      // Keep the last known state on a failed poll rather than flashing
      // an error banner every 45 seconds on a flaky connection.
    }
  }

  Future<void> refreshNow() => _refresh();
}

final currentLiveSessionProvider =
    AsyncNotifierProvider<CurrentLiveSessionNotifier, LiveSession?>(
  CurrentLiveSessionNotifier.new,
);

/// Pastor-facing: start/end their own live session.
class PastorLiveNotifier extends Notifier<LiveSession?> {
  final _api = LiveSessionApi();

  @override
  LiveSession? build() => null;

  Future<void> goLive({required String preacherId, required String title}) async {
    final session = await _api.startLiveSession(preacherId: preacherId, title: title);
    state = session;
  }

  Future<void> endLive() async {
    if (state == null) return;
    await _api.endLiveSession(state!.id);
    state = null;
  }
}

final pastorLiveProvider =
    NotifierProvider<PastorLiveNotifier, LiveSession?>(PastorLiveNotifier.new);