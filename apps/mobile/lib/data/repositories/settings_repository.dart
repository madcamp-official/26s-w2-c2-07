import '../../core/network/api_client.dart';
import '../models/profile.dart';
import 'memory_cache.dart';

class SettingsRepository {
  SettingsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ProfileSettings> get() async {
    final cached = repositoryCache.read<ProfileSettings>('settings');
    if (cached != null) return cached;

    final data = await _apiClient.get('/settings') as Map<String, dynamic>;
    final settings = ProfileSettings.fromJson(data);
    repositoryCache.write('settings', settings);
    return settings;
  }

  Future<ProfileSettings> update({
    bool? captureAlertsEnabled,
    bool? darkEditorEnabled,
  }) async {
    final data = await _apiClient.patch('/settings', body: {
      if (captureAlertsEnabled != null) 'captureAlertsEnabled': captureAlertsEnabled,
      if (darkEditorEnabled != null) 'darkEditorEnabled': darkEditorEnabled,
    }) as Map<String, dynamic>;
    final settings = ProfileSettings.fromJson(data);
    repositoryCache.write('settings', settings);
    repositoryCache.remove('me');
    return settings;
  }
}
