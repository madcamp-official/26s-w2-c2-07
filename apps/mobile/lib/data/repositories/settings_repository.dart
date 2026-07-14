import '../../core/network/api_client.dart';
import '../models/profile.dart';

class SettingsRepository {
  SettingsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ProfileSettings> get() async {
    final data = await _apiClient.get('/settings') as Map<String, dynamic>;
    return ProfileSettings.fromJson(data);
  }

  Future<ProfileSettings> update({
    bool? captureAlertsEnabled,
    bool? darkEditorEnabled,
  }) async {
    final data = await _apiClient.patch('/settings', body: {
      if (captureAlertsEnabled != null) 'captureAlertsEnabled': captureAlertsEnabled,
      if (darkEditorEnabled != null) 'darkEditorEnabled': darkEditorEnabled,
    }) as Map<String, dynamic>;
    return ProfileSettings.fromJson(data);
  }
}
