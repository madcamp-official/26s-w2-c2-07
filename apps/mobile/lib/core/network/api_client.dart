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
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final request = http.Request('GET', Uri.parse('$_baseUrl$path'))
      ..headers.addAll({
        if (token != null) 'Authorization': 'Bearer $token',
      });

    final response = await http.Response.fromStream(await _client.send(request));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = response.body.isEmpty ? null : jsonDecode(response.body);
      throw ApiException(response.statusCode, payload?['error']?['message']);
    }
    return response;
  }

  Future<dynamic> _request(String method, String path, {Object? body}) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers.addAll({
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);

    final response =
        await http.Response.fromStream(await _client.send(request));
    final payload = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, payload?['error']?['message']);
    }
    return payload;
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String? message;

  @override
  String toString() => message ?? 'API error $statusCode';
}
