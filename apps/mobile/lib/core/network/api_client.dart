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
    final token = await _requireAccessToken();
    final request = http.Request('GET', Uri.parse('$_baseUrl$path'))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      });

    final response = await http.Response.fromStream(await _client.send(request));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _errorMessage(response.body));
    }
    return response;
  }

  Future<dynamic> _request(String method, String path, {Object? body}) async {
    final token = await _requireAccessToken();
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);

    final response =
        await http.Response.fromStream(await _client.send(request));
    final payload = _tryDecodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _errorMessage(response.body));
    }
    return payload;
  }

  dynamic _tryDecodeJson(String body) {
    if (body.isEmpty) return null;

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
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

  Future<String> _requireAccessToken() async {
    final auth = Supabase.instance.client.auth;
    final currentToken = auth.currentSession?.accessToken;

    if (currentToken != null && currentToken.isNotEmpty) {
      return currentToken;
    }

    try {
      final refreshed = await auth.refreshSession();
      final refreshedToken =
          refreshed.session?.accessToken ?? auth.currentSession?.accessToken;

      if (refreshedToken != null && refreshedToken.isNotEmpty) {
        return refreshedToken;
      }
    } catch (_) {
      // The app will surface the auth error below and route the user back to login.
    }

    await auth.signOut();
    throw const AuthRequiredException();
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
