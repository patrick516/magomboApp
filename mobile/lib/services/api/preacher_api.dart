import '../api_service.dart';
import '../../models/preacher.dart';

class PreacherApi {
  final _dio = ApiService.instance.client;

  Future<List<Preacher>> listPreachers() async {
    final response = await _dio.get('/preachers');
    final List data = response.data['data'] as List;
    return data.map((json) => Preacher.fromJson(json)).toList();
  }

  Future<Preacher> registerPreacher(Preacher preacher) async {
    final response = await _dio.post('/preachers', data: preacher.toJson());
    return Preacher.fromJson(response.data['data']);
  }
}