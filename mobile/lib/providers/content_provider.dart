// lib/providers/content_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement.dart';
import '../models/small_group.dart';
import '../models/testimony.dart';
import '../services/api/announcement_api.dart';
import '../services/api/small_group_api.dart';
import '../services/api/testimony_api.dart';

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  return AnnouncementApi().listAnnouncements();
});

final smallGroupsProvider = FutureProvider<List<SmallGroup>>((ref) async {
  return SmallGroupApi().listSmallGroups();
});

final testimoniesProvider = FutureProvider<List<Testimony>>((ref) async {
  return TestimonyApi().listApprovedTestimonies();
});