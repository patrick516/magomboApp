// lib/providers/preacher_stats_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/sermon_repository.dart';
import '../repositories/preaching_repository.dart';

class PreacherStats {
  final int sermonCount;
  final int partCount;
  final int totalPlays;

  const PreacherStats({
    required this.sermonCount,
    required this.partCount,
    required this.totalPlays,
  });
}

final preacherStatsProvider =
    FutureProvider.family<PreacherStats, String>((ref, preacherId) async {
  final sermons = await SermonRepository().getByPreacher(preacherId);
  final partCount =
      await PreachingRepository().getTotalPartsForPreacher(preacherId);
  final totalPlays =
      await PreachingRepository().getTotalPlaysForPreacher(preacherId);

  return PreacherStats(
    sermonCount: sermons.length,
    partCount: partCount,
    totalPlays: totalPlays,
  );
});