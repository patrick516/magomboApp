// lib/services/api/small_group_api.dart

import '../api_service.dart';
import '../../models/small_group.dart';

class SmallGroupApi {
  final _dio = ApiService.instance.client;

  Future<List<SmallGroup>> listSmallGroups() async {
    final response = await _dio.get('/small-groups');
    final List data = response.data['data'] as List;
    return data.map((json) => SmallGroup.fromJson(json)).toList();
  }

  Future<SmallGroup> getGroup(String id, {String? deviceId}) async {
    final response = await _dio.get('/small-groups/$id', queryParameters: {
      if (deviceId != null) 'deviceId': deviceId,
    });
    return SmallGroup.fromJson(response.data['data']);
  }

  Future<void> joinGroup(String id, {required String deviceId, required String memberName}) async {
    await _dio.post('/small-groups/$id/join', data: {
      'deviceId': deviceId,
      'memberName': memberName,
    });
  }

  Future<void> leaveGroup(String id, {required String deviceId}) async {
    await _dio.post('/small-groups/$id/leave', data: {'deviceId': deviceId});
  }
}