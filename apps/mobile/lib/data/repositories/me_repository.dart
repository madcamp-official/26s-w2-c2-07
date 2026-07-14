import '../../core/network/api_client.dart';
import '../models/profile.dart';

class MeRepository {
  MeRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Profile> get() async {
    final data = await _apiClient.get('/me') as Map<String, dynamic>;
    return Profile.fromJson(data);
  }

  Future<Profile> update({String? displayName, String? avatarUrl}) async {
    final data = await _apiClient.patch('/me', body: {
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    }) as Map<String, dynamic>;
    return Profile.fromJson(data);
  }

  Future<void> delete() => _apiClient.delete('/me');
}
