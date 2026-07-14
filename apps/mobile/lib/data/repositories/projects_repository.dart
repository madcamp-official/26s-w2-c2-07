import '../../core/network/api_client.dart';
import '../models/capture.dart';
import '../models/project.dart';

class ProjectExportResult {
  const ProjectExportResult({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });

  final List<int> bytes;
  final String filename;
  final String contentType;
}

class ProjectsRepository {
  ProjectsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Project>> list() async {
    final data = await _apiClient.get('/projects') as List<dynamic>;
    return data.map((json) => Project.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Project> get(String id) async {
    final data = await _apiClient.get('/projects/$id') as Map<String, dynamic>;
    return Project.fromJson(data);
  }

  Future<Project> create({required String title, String? description}) async {
    final data = await _apiClient.post('/projects', body: {
      'title': title,
      if (description != null) 'description': description,
    }) as Map<String, dynamic>;
    return Project.fromJson(data);
  }

  Future<Project> update(String id, {String? title, String? description}) async {
    final data = await _apiClient.patch('/projects/$id', body: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    }) as Map<String, dynamic>;
    return Project.fromJson(data);
  }

  Future<Project> updateStatus(String id, ProjectStatus status) async {
    final data = await _apiClient.patch('/projects/$id/status', body: {
      'status': status.name,
    }) as Map<String, dynamic>;
    return Project.fromJson(data);
  }

  Future<void> delete(String id) => _apiClient.delete('/projects/$id');

  Future<List<Capture>> listCaptures(String projectId) async {
    final data = await _apiClient.get('/projects/$projectId/captures') as List<dynamic>;
    return data.map((json) => Capture.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> linkCapture(String projectId, String captureId) {
    return _apiClient.post('/projects/$projectId/captures', body: {'captureId': captureId});
  }

  Future<void> unlinkCapture(String projectId, String captureId) {
    return _apiClient.delete('/projects/$projectId/captures/$captureId');
  }

  Future<ProjectExportResult> export(String projectId, String format) async {
    final response = await _apiClient.getRaw('/projects/$projectId/export?format=$format');
    final rawContentType = response.headers['content-type'] ?? 'application/octet-stream';
    // XFile's mimeType must be a bare MIME type; strip params like "; charset=utf-8".
    final contentType = rawContentType.split(';').first.trim();
    final disposition = response.headers['content-disposition'] ?? '';
    final match = RegExp(r"filename\*=UTF-8''([^;]+)").firstMatch(disposition);
    final filename = match != null
        ? Uri.decodeComponent(match.group(1)!)
        : 'export.$format';
    return ProjectExportResult(
      bytes: response.bodyBytes,
      filename: filename,
      contentType: contentType,
    );
  }
}
