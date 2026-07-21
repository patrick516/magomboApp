import '../api_service.dart';
import '../../models/sermon.dart';

class SermonApi {
  final _dio = ApiService.instance.client;

  Future<List<Sermon>> listSermons({String? preacherId, String? since}) async {
    final response = await _dio.get('/sermons', queryParameters: {
      'preacherId': ?preacherId,
      'since': ?since,
    });
    final List data = response.data['data'] as List;
    return data.map((json) => Sermon.fromJson(json)).toList();
  }

  Future<Sermon> createSermon(Sermon sermon) async {
    final response = await _dio.post('/sermons', data: sermon.toJson());
    return Sermon.fromJson(response.data['data']);
  }
}