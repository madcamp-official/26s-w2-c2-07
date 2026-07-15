import '../../core/network/api_client.dart';
import '../models/capture.dart';
import '../models/project.dart';
import 'memory_cache.dart';

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
    final cached = repositoryCache.read<List<Project>>('projects:list');
    if (cached != null) return cached;

    final data = await _apiClient.get('/projects') as List<dynamic>;
    final projects =
        data.map((json) => Project.fromJson(json as Map<String, dynamic>)).toList();
    repositoryCache.write('projects:list', projects);
    return projects;
  }

  Future<Project> get(String id) async {
    final cached = repositoryCache.read<Project>('projects:item:$id');
    if (cached != null) return cached;

    final data = await _apiClient.get('/projects/$id') as Map<String, dynamic>;
    final project = Project.fromJson(data);
    repositoryCache.write('projects:item:$id', project);
    return project;
  }

  Future<Project> create({required String title, String? description}) async {
    final data = await _apiClient.post('/projects', body: {
      'title': title,
      if (description != null) 'description': description,
    }) as Map<String, dynamic>;
    final project = Project.fromJson(data);
    _invalidateProjects();
    repositoryCache.write('projects:item:${project.id}', project);
    return project;
  }

  Future<Project> update(String id, {String? title, String? description}) async {
    final data = await _apiClient.patch('/projects/$id', body: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    }) as Map<String, dynamic>;
    final project = Project.fromJson(data);
    _invalidateProjects();
    repositoryCache.write('projects:item:${project.id}', project);
    return project;
  }

  Future<Project> updateStatus(String id, ProjectStatus status) async {
    final data = await _apiClient.patch('/projects/$id/status', body: {
      'status': status.name,
    }) as Map<String, dynamic>;
    final project = Project.fromJson(data);
    _invalidateProjects();
    repositoryCache.write('projects:item:${project.id}', project);
    return project;
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('/projects/$id');
    _invalidateProjects();
    repositoryCache.remove('projects:item:$id');
  }

  Future<List<Capture>> listCaptures(String projectId) async {
    final cacheKey = 'projects:captures:$projectId';
    final cached = repositoryCache.read<List<Capture>>(cacheKey);
    if (cached != null) return cached;

    final data = await _apiClient.get('/projects/$projectId/captures') as List<dynamic>;
    final captures =
        data.map((json) => Capture.fromJson(json as Map<String, dynamic>)).toList();
    repositoryCache.write(cacheKey, captures);
    return captures;
  }

  Future<void> linkCapture(String projectId, String captureId) async {
    await _apiClient.post('/projects/$projectId/captures', body: {'captureId': captureId});
    repositoryCache.remove('projects:captures:$projectId');
  }

  Future<void> unlinkCapture(String projectId, String captureId) async {
    await _apiClient.delete('/projects/$projectId/captures/$captureId');
    repositoryCache.remove('projects:captures:$projectId');
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

  void _invalidateProjects() {
    repositoryCache.remove('projects:list');
    repositoryCache.removeWhere((key) => key.startsWith('projects:captures:'));
  }
}
