import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';

enum SyncState { idle, syncing, success, failure }

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => SyncState.idle;

  Future<void> sync() async {
    state = SyncState.syncing;
    try {
      await SyncService().syncAll();
      state = SyncState.success;
    } catch (_) {
      state = SyncState.failure;
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);