import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import 'sermon_browse_provider.dart';
import 'preacher_provider.dart';

enum SyncState { idle, syncing, success, failure }

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => SyncState.idle;

  Future<void> sync() async {
    state = SyncState.syncing;
    try {
      await SyncService().syncAll();
      state = SyncState.success;

      // Refresh anything reading local data, since sync just updated it
      ref.invalidate(allPreachersProvider);
      ref.invalidate(devicePreachersProvider);
      // Note: sermonsByPreacherProvider and partsBySermonProvider are
      // family providers — invalidated individually where they're used,
      // since we don't know every argument combo in use here.
    } catch (_) {
      state = SyncState.failure;
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);