// lib/services/api/group_post_api.dart

import '../api_service.dart';
import '../../models/group_post.dart';

class GroupPostApi {
  final _dio = ApiService.instance.client;

  Future<List<GroupPost>> listPosts(String groupId) async {
    final response = await _dio.get('/small-groups/$groupId/posts');
    final List data = response.data['data'] as List;
    return data.map((json) => GroupPost.fromJson(json)).toList();
  }

  Future<void> createPost(String groupId,
      {required String deviceId, required String authorName, required String message}) async {
    await _dio.post('/small-groups/$groupId/posts', data: {
      'deviceId': deviceId,
      'authorName': authorName,
      'message': message,
    });
  }

  Future<void> createComment(String groupId, String postId,
      {required String deviceId, required String authorName, required String message}) async {
    await _dio.post('/small-groups/$groupId/posts/$postId/comments', data: {
      'deviceId': deviceId,
      'authorName': authorName,
      'message': message,
    });
  }
}