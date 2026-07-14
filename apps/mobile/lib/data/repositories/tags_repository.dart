import '../../core/network/api_client.dart';
import '../models/tag.dart';

class TagsRepository {
  TagsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Tag>> list() async {
    final data = await _apiClient.get('/tags') as List<dynamic>;
    return data.map((json) => Tag.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Tag> create(String name, {String? color}) async {
    final data = await _apiClient.post('/tags', body: {
      'name': name,
      if (color != null) 'color': color,
    }) as Map<String, dynamic>;
    return Tag.fromJson(data);
  }

  Future<void> delete(String id) => _apiClient.delete('/tags/$id');
}
