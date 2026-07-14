import '../../core/network/api_client.dart';
import '../models/document.dart';

class DocumentsRepository {
  DocumentsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ManuscriptDocument>> list(String projectId) async {
    final data = await _apiClient.get('/projects/$projectId/documents') as List<dynamic>;
    return data
        .map((json) => ManuscriptDocument.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ManuscriptDocument> get(String projectId, String documentId) async {
    final data = await _apiClient.get('/projects/$projectId/documents/$documentId')
        as Map<String, dynamic>;
    return ManuscriptDocument.fromJson(data);
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
    return ManuscriptDocument.fromJson(data);
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
    return ManuscriptDocument.fromJson(data);
  }

  Future<void> delete(String projectId, String documentId) {
    return _apiClient.delete('/projects/$projectId/documents/$documentId');
  }
}
