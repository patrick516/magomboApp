import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/preacher_repository.dart';
import '../repositories/sermon_repository.dart';
import '../repositories/preaching_repository.dart';
import 'api/preacher_api.dart';
import 'api/sermon_api.dart';
import 'api/preaching_api.dart';

class SyncService {
  final _preacherApi = PreacherApi();
  final _sermonApi = SermonApi();
  final _preachingApi = PreachingApi();

  final _preacherRepo = PreacherRepository();
  final _sermonRepo = SermonRepository();
  final _preachingRepo = PreachingRepository();

  Future<void> syncAll() async {
    await _pushPreachers();
    await _pushSermons();
    await _pushPreachings();
    await _pullLatest();
  }

  Future<void> _pushPreachers() async {
    final unsynced = await _preacherRepo.getUnsynced();
    for (final preacher in unsynced) {
      try {
        await _preacherApi.registerPreacher(preacher);
        await _preacherRepo.markSynced(preacher.id);
      } catch (_) {}
    }
  }

  Future<void> _pushSermons() async {
    final unsynced = await _sermonRepo.getUnsynced();
    for (final sermon in unsynced) {
      try {
        await _sermonApi.createSermon(sermon);
        await _sermonRepo.markSynced(sermon.id);
      } catch (_) {}
    }
  }

  Future<void> _pushPreachings() async {
    final unsynced = await _preachingRepo.getUnsynced();
    for (final preaching in unsynced) {
      try {
        final uploaded =
            await _preachingApi.uploadPreaching(preaching.sermonId, preaching);
        await _preachingRepo.markSynced(preaching.id, cloudUrl: uploaded.cloudUrl);
      } catch (e) {
        // ignore: avoid_print
        print('Preaching upload failed for ${preaching.id}: $e');
        // leave unsynced, retried on next sync
      }
    }
  }

  Future<void> _pullLatest() async {
    final prefs = await SharedPreferences.getInstance();
    final since = prefs.getString('last_sync_at');

    final preachers = await _preacherApi.listPreachers();
    for (final preacher in preachers) {
      await _preacherRepo.insert(preacher);
    }

    final sermons = await _sermonApi.listSermons(since: since);
    for (final sermon in sermons) {
      await _sermonRepo.insert(sermon);
      final preachings = await _preachingApi.listPreachingsForSermon(sermon.id);
      for (final preaching in preachings) {
        await _preachingRepo.insert(preaching);
      }
    }

    await prefs.setString('last_sync_at', DateTime.now().toIso8601String());
  }
}