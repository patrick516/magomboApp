// lib/services/api/testimony_api.dart

import '../api_service.dart';
import '../../models/testimony.dart';

class TestimonyApi {
  final _dio = ApiService.instance.client;

  Future<void> createTestimony(Testimony testimony) async {
    await _dio.post('/testimonies', data: testimony.toJson());
  }

  Future<List<Testimony>> listApprovedTestimonies() async {
    final response = await _dio.get('/testimonies');
    final List data = response.data['data'] as List;
    return data.map((json) => Testimony.fromJson(json)).toList();
  }
}