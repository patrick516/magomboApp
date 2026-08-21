// lib/providers/group_detail_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/small_group.dart';
import '../models/group_post.dart';
import '../services/api/small_group_api.dart';
import '../services/api/group_post_api.dart';
import '../services/device_service.dart';

final groupDetailProvider =
    FutureProvider.family<SmallGroup, String>((ref, groupId) async {
  final deviceId = await DeviceService.getDeviceId();
  return SmallGroupApi().getGroup(groupId, deviceId: deviceId);
});

final groupPostsProvider =
    FutureProvider.family<List<GroupPost>, String>((ref, groupId) async {
  return GroupPostApi().listPosts(groupId);
});