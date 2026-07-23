import 'package:dio/dio.dart';
import '../api_service.dart';
import '../../models/preaching.dart';

class PreachingApi {
  final _dio = ApiService.instance.client;

  Future<List<Preaching>> listPreachingsForSermon(String sermonId) async {
    final response = await _dio.get('/sermons/$sermonId/preachings');
    final List data = response.data['data'] as List;
    return data.map((json) => Preaching.fromJson(json)).toList();
  }

  /// Uploads the actual audio file (multipart/form-data) along with metadata.
  /// Requires the preaching to have a valid localFilePath.
  Future<Preaching> uploadPreaching(String sermonId, Preaching preaching) async {
    if (preaching.localFilePath == null) {
      throw Exception('No local audio file to upload for this preaching');
    }

    final formData = FormData.fromMap({
      'dateRecorded': preaching.dateRecorded,
      'durationSeconds': preaching.durationSeconds.toString(),
      'audio': await MultipartFile.fromFile(
        preaching.localFilePath!,
        filename: '${preaching.id}.m4a',
      ),
    });

    final response = await _dio.post(
      '/sermons/$sermonId/preachings',
      data: formData,
    );
    return Preaching.fromJson(response.data['data']);
  }

/// Fetches the actual playable signed URL from the backend.
  /// The /audio endpoint now returns JSON { success, data: { signedUrl } }
  /// rather than an HTTP redirect, so this must be awaited before playback.
  Future<String> getSignedAudioUrl(String preachingId) async {
    final response = await _dio.get('/preachings/$preachingId/audio');
    final signedUrl = response.data['data']['signedUrl'] as String?;
    if (signedUrl == null) {
      throw Exception('Backend did not return a signedUrl for this preaching');
    }
    return signedUrl;
  }

  Future<void> incrementPlayCount(String preachingId) async {
    await _dio.post('/preachings/$preachingId/play');
  }
}