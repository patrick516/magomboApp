// lib/services/api/live_session_api.dart

import '../api_service.dart';
import '../../models/live_session.dart';

class LiveSessionApi {
  final _dio = ApiService.instance.client;

  Future<LiveSession?> getCurrentLiveSession() async {
    final response = await _dio.get('/live-sessions/current');
    final data = response.data['data'];
    if (data == null) return null;
    return LiveSession.fromJson(data);
  }

  Future<LiveSession> startLiveSession({
    required String preacherId,
    required String title,
  }) async {
    final response = await _dio.post('/live-sessions', data: {
      'preacherId': preacherId,
      'title': title,
    });
    return LiveSession.fromJson(response.data['data']);
  }

  Future<LiveSession> endLiveSession(String id) async {
    final response = await _dio.post('/live-sessions/$id/end');
    return LiveSession.fromJson(response.data['data']);
  }
}