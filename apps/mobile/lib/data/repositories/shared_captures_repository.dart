import '../../core/network/api_client.dart';
import '../models/capture.dart';
import '../models/shared_capture.dart';

class SharedCapturesRepository {
  SharedCapturesRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<SharedCapture>> list({String? query}) async {
    final text = query?.trim();
    final path = text == null || text.isEmpty
        ? '/shared-captures'
        : '/shared-captures?q=${Uri.encodeQueryComponent(text)}';
    final data = await _apiClient.get(path) as List<dynamic>;

    return data
        .map((json) => SharedCapture.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Capture?> save(String id) async {
    final data = await _apiClient.post('/shared-captures/$id/save');
    if (data == null) return null;
    return Capture.fromJson(data as Map<String, dynamic>);
  }

  Future<void> report(String id, {required String reason}) {
    return _apiClient.post('/shared-captures/$id/report', body: {
      'reason': reason,
    });
  }
}
