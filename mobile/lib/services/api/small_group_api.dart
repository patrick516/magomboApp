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
}