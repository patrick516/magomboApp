// lib/services/api/announcement_api.dart

import '../api_service.dart';
import '../../models/announcement.dart';

class AnnouncementApi {
  final _dio = ApiService.instance.client;

  Future<List<Announcement>> listAnnouncements() async {
    final response = await _dio.get('/announcements');
    final List data = response.data['data'] as List;
    return data.map((json) => Announcement.fromJson(json)).toList();
  }
}