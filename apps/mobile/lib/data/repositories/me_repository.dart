import '../../core/network/api_client.dart';
import '../models/profile.dart';
import 'memory_cache.dart';

class MeRepository {
  MeRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Profile> get() async {
    final cached = repositoryCache.read<Profile>('me');
    if (cached != null) return cached;

    final data = await _apiClient.get('/me') as Map<String, dynamic>;
    final profile = Profile.fromJson(data);
    repositoryCache.write('me', profile);
    return profile;
  }

  Future<Profile> update({String? displayName, String? avatarUrl}) async {
    final data = await _apiClient.patch('/me', body: {
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    }) as Map<String, dynamic>;
    final profile = Profile.fromJson(data);
    repositoryCache.write('me', profile);
    return profile;
  }

  Future<void> delete() async {
    await _apiClient.delete('/me');
    repositoryCache.clear();
  }
}
