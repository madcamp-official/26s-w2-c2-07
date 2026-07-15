import '../../core/network/api_client.dart';
import '../models/tag.dart';
import 'memory_cache.dart';

class TagsRepository {
  TagsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Tag>> list() async {
    final cached = repositoryCache.read<List<Tag>>('tags:list');
    if (cached != null) return cached;

    final data = await _apiClient.get('/tags') as List<dynamic>;
    final tags =
        data.map((json) => Tag.fromJson(json as Map<String, dynamic>)).toList();
    repositoryCache.write('tags:list', tags);
    return tags;
  }

  Future<Tag> create(String name, {String? color}) async {
    final data = await _apiClient.post('/tags', body: {
      'name': name,
      if (color != null) 'color': color,
    }) as Map<String, dynamic>;
    final tag = Tag.fromJson(data);
    repositoryCache.remove('tags:list');
    return tag;
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('/tags/$id');
    repositoryCache.remove('tags:list');
  }
}
