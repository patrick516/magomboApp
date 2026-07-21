import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/preacher.dart';
import '../models/sermon.dart';
import '../models/preaching.dart';
import '../repositories/preacher_repository.dart';
import '../repositories/sermon_repository.dart';
import '../repositories/preaching_repository.dart';

final allPreachersProvider = FutureProvider<List<Preacher>>((ref) async {
  return PreacherRepository().getAll();
});

final sermonsByPreacherProvider =
    FutureProvider.family<List<Sermon>, String>((ref, preacherId) async {
  return SermonRepository().getByPreacher(preacherId);
});

final partsBySermonProvider =
    FutureProvider.family<List<Preaching>, String>((ref, sermonId) async {
  return PreachingRepository().getBySermon(sermonId);
});