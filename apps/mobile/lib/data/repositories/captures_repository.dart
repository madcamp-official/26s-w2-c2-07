import '../../core/network/api_client.dart';
import '../models/capture.dart';

class CapturesRepository {
  CapturesRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Capture>> list({CaptureType? type}) async {
    final query = type != null ? '?type=${type.name}' : '';
    final data = await _apiClient.get('/captures$query') as List<dynamic>;
    return data.map((json) => Capture.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Capture> get(String id) async {
    final data = await _apiClient.get('/captures/$id') as Map<String, dynamic>;
    return Capture.fromJson(data);
  }

  Future<Capture> create({
    required CaptureType type,
    String? content,
    String? url,
    List<String>? tagIds,
  }) async {
    final data = await _apiClient.post('/captures', body: {
      'type': type.name,
      if (content != null) 'content': content,
      if (url != null) 'url': url,
      if (tagIds != null) 'tagIds': tagIds,
    }) as Map<String, dynamic>;
    return Capture.fromJson(data);
  }

  Future<Capture> update(
    String id, {
    String? content,
    String? url,
    List<String>? tagIds,
  }) async {
    final data = await _apiClient.patch('/captures/$id', body: {
      if (content != null) 'content': content,
      if (url != null) 'url': url,
      if (tagIds != null) 'tagIds': tagIds,
    }) as Map<String, dynamic>;
    return Capture.fromJson(data);
  }

  Future<void> delete(String id) => _apiClient.delete('/captures/$id');

  Future<Map<String, dynamic>> createUploadUrl(
    String captureId, {
    required String fileName,
    required String contentType,
  }) async {
    final data = await _apiClient.post('/captures/$captureId/assets/upload-url', body: {
      'fileName': fileName,
      'contentType': contentType,
    }) as Map<String, dynamic>;
    return data;
  }

  Future<void> completeUpload(String captureId, String storagePath) {
    return _apiClient.post('/captures/$captureId/assets/complete', body: {
      'storagePath': storagePath,
    });
  }
}
