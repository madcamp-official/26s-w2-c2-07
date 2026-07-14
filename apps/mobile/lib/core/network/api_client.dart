import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final rawUrl = dotenv.env['API_URL'] ??
        dotenv.env['NOOK_BACKEND_URL'] ??
        dotenv.env['NEXT_PUBLIC_API_URL'];

    if (rawUrl == null || rawUrl.trim().isEmpty) {
      throw const ApiException(
        0,
        'API_URL 또는 NOOK_BACKEND_URL이 .env에 설정되어 있지 않습니다.',
      );
    }

    final url = rawUrl.trim().replaceAll(RegExp(r'/$'), '');

    if (!kIsWeb && Platform.isAndroid) {
      return url
          .replaceFirst('localhost', '10.0.2.2')
          .replaceFirst('127.0.0.1', '10.0.2.2');
    }

    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return url.replaceFirst('10.0.2.2', '127.0.0.1');
    }

    return url;
  }

  Future<dynamic> get(String path) => _request('GET', path);

  Future<dynamic> post(String path, {Object? body}) =>
      _request('POST', path, body: body);

  Future<dynamic> patch(String path, {Object? body}) =>
      _request('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _request('DELETE', path);

  /// For endpoints that return a binary body (e.g. project export) instead of JSON.
  Future<http.Response> getRaw(String path) async {
    final response = await _send('GET', path);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _errorMessage(response.body));
    }
    return response;
  }

  Future<dynamic> _request(String method, String path, {Object? body}) async {
    final response = await _send(method, path, body: body);
    final payload = _tryDecodeJson(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _errorMessage(response.body));
    }

    return payload;
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
  }) async {
    final firstToken = await _requireAccessToken();
    final firstResponse = await _sendOnce(
      method,
      path,
      accessToken: firstToken,
      body: body,
    );

    if (!_isMissingAccessToken(firstResponse)) return firstResponse;

    final refreshedToken = await _requireAccessToken(forceRefresh: true);
    return _sendOnce(
      method,
      path,
      accessToken: refreshedToken,
      body: body,
    );
  }

  Future<http.Response> _sendOnce(
    String method,
    String path, {
    required String accessToken,
    Object? body,
  }) {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {
      'content-type': 'application/json',
      'authorization': 'Bearer $accessToken',
    };
    final encodedBody = body == null ? null : jsonEncode(body);

    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return _client.delete(uri, headers: headers);
      default:
        return _client.send(
          http.Request(method, uri)
            ..headers.addAll(headers)
            ..body = encodedBody ?? '',
        ).then(http.Response.fromStream);
    }
  }

  dynamic _tryDecodeJson(String body) {
    if (body.isEmpty) return null;

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  bool _isMissingAccessToken(http.Response response) {
    if (response.statusCode != 401) return false;
    return _errorMessage(response.body) == 'Missing access token';
  }

  String? _errorMessage(String body) {
    final payload = _tryDecodeJson(body);
    if (payload is Map<String, dynamic>) {
      final error = payload['error'];
      if (error is Map<String, dynamic>) return error['message'] as String?;
      if (error is String) return error;
      return payload['message'] as String?;
    }
    return payload is String && payload.isNotEmpty ? payload : null;
  }

  // Shared across every ApiClient instance so concurrent 401s from multiple
  // screens await the same in-flight refresh instead of each calling
  // auth.refreshSession() independently. Supabase rotates refresh tokens on
  // use, so parallel calls with the same stale token would otherwise race:
  // only the first succeeds and the rest fail as "already used", which was
  // triggering a signOut() and wiping the session that the first call just
  // obtained.
  static Future<String?>? _pendingRefresh;

  Future<String> _requireAccessToken({bool forceRefresh = false}) async {
    final auth = Supabase.instance.client.auth;
    final currentToken = auth.currentSession?.accessToken;

    if (!forceRefresh && currentToken != null && currentToken.isNotEmpty) {
      return currentToken;
    }

    final refreshedToken = await (_pendingRefresh ??= _refreshOnce());
    _pendingRefresh = null;

    if (refreshedToken != null && refreshedToken.isNotEmpty) {
      return refreshedToken;
    }

    await auth.signOut();
    throw const AuthRequiredException();
  }

  Future<String?> _refreshOnce() async {
    final auth = Supabase.instance.client.auth;

    try {
      final refreshed = await auth.refreshSession();
      return refreshed.session?.accessToken ?? auth.currentSession?.accessToken;
    } catch (_) {
      return null;
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String? message;

  @override
  String toString() => message ?? 'API error $statusCode';
}

class AuthRequiredException extends ApiException {
  const AuthRequiredException()
      : super(401, '로그인이 만료되었습니다. 다시 로그인해 주세요.');
}
