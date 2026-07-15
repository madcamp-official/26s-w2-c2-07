import '../../core/network/api_client.dart';
import '../models/document.dart';
import 'memory_cache.dart';

class DocumentsRepository {
  DocumentsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ManuscriptDocument>> list(String projectId) async {
    final cacheKey = 'documents:list:$projectId';
    final cached = repositoryCache.read<List<ManuscriptDocument>>(cacheKey);
    if (cached != null) return cached;

    final data = await _apiClient.get('/projects/$projectId/documents') as List<dynamic>;
    final documents = data
        .map((json) => ManuscriptDocument.fromJson(json as Map<String, dynamic>))
        .toList();
    repositoryCache.write(cacheKey, documents);
    return documents;
  }

  Future<ManuscriptDocument> get(String projectId, String documentId) async {
    final cacheKey = 'documents:item:$projectId:$documentId';
    final cached = repositoryCache.read<ManuscriptDocument>(cacheKey);
    if (cached != null) return cached;

    final data = await _apiClient.get('/projects/$projectId/documents/$documentId')
        as Map<String, dynamic>;
    final document = ManuscriptDocument.fromJson(data);
    repositoryCache.write(cacheKey, document);
    return document;
  }

  Future<ManuscriptDocument> create(
    String projectId, {
    required String title,
    required String content,
  }) async {
    final data = await _apiClient.post('/projects/$projectId/documents', body: {
      'title': title,
      'content': content,
    }) as Map<String, dynamic>;
    final document = ManuscriptDocument.fromJson(data);
    _invalidateProjectDocuments(projectId);
    repositoryCache.write('documents:item:$projectId:${document.id}', document);
    return document;
  }

  Future<ManuscriptDocument> update(
    String projectId,
    String documentId, {
    String? title,
    String? content,
  }) async {
    final data = await _apiClient.patch('/projects/$projectId/documents/$documentId', body: {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
    }) as Map<String, dynamic>;
    final document = ManuscriptDocument.fromJson(data);
    _invalidateProjectDocuments(projectId);
    repositoryCache.write('documents:item:$projectId:$documentId', document);
    return document;
  }

  Future<void> delete(String projectId, String documentId) async {
    await _apiClient.delete('/projects/$projectId/documents/$documentId');
    _invalidateProjectDocuments(projectId);
    repositoryCache.remove('documents:item:$projectId:$documentId');
  }

  void _invalidateProjectDocuments(String projectId) {
    repositoryCache.remove('documents:list:$projectId');
  }
}
