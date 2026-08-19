// lib/services/api/prayer_request_api.dart

import '../api_service.dart';
import '../../models/prayer_request.dart';

class PrayerRequestApi {
  final _dio = ApiService.instance.client;

  Future<void> createPrayerRequest(PrayerRequestSubmission request) async {
    await _dio.post('/prayer-requests', data: request.toJson());
  }
}