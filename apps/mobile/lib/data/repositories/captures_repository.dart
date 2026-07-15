import '../../core/network/api_client.dart';
import '../models/capture.dart';
import 'memory_cache.dart';

class CapturesRepository {
  CapturesRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Capture>> list({CaptureType? type}) async {
    final cacheKey = 'captures:list:${type?.name ?? 'all'}';
    final cached = repositoryCache.read<List<Capture>>(cacheKey);
    if (cached != null) return cached;

    final query = type != null ? '?type=${type.name}' : '';
    final data = await _apiClient.get('/captures$query') as List<dynamic>;
    final captures = data
        .map((json) => Capture.fromJson(json as Map<String, dynamic>))
        .toList();
    repositoryCache.write(cacheKey, captures);
    return captures;
  }

  Future<Capture> get(String id) async {
    final cached = repositoryCache.read<Capture>('captures:item:$id');
    if (cached != null) return cached;

    final data = await _apiClient.get('/captures/$id') as Map<String, dynamic>;
    final capture = Capture.fromJson(data);
    repositoryCache.write('captures:item:$id', capture);
    return capture;
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
    final capture = Capture.fromJson(data);
    _invalidateCaptures();
    repositoryCache.write('captures:item:${capture.id}', capture);
    return capture;
  }

  Future<Capture> update(
    String id, {
    String? content,
    String? url,
    List<String>? tagIds,
    bool? isShared,
  }) async {
    final data = await _apiClient.patch('/captures/$id', body: {
      if (content != null) 'content': content,
      if (url != null) 'url': url,
      if (tagIds != null) 'tagIds': tagIds,
      if (isShared != null) 'isShared': isShared,
    }) as Map<String, dynamic>;
    final capture = Capture.fromJson(data);
    _invalidateCaptures();
    repositoryCache.write('captures:item:${capture.id}', capture);
    return capture;
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('/captures/$id');
    _invalidateCaptures();
    repositoryCache.remove('captures:item:$id');
  }

  Future<Map<String, dynamic>> createUploadUrl(
    String captureId, {
    required String fileName,
    required String contentType,
  }) async {
    final data =
        await _apiClient.post('/captures/$captureId/assets/upload-url', body: {
      'fileName': fileName,
      'contentType': contentType,
    }) as Map<String, dynamic>;
    return data;
  }

  Future<void> completeUpload(String captureId, String storagePath) {
    _invalidateCaptures();
    repositoryCache.remove('captures:item:$captureId');
    return _apiClient.post('/captures/$captureId/assets/complete', body: {
      'storagePath': storagePath,
    });
  }

  void _invalidateCaptures() {
    repositoryCache.removeWhere((key) => key.startsWith('captures:'));
    repositoryCache.removeWhere((key) => key.startsWith('projects:captures:'));
  }
}
