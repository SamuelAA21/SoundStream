import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_exception.dart';

typedef AccessTokenProvider = String? Function();
typedef SessionRefresher = Future<bool> Function();
typedef UnauthorizedHandler = Future<void> Function();

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.client,
    required this.accessTokenProvider,
    required this.refreshSession,
    required this.onUnauthorized,
  });

  final String baseUrl;
  final http.Client client;
  final AccessTokenProvider accessTokenProvider;
  final SessionRefresher refreshSession;
  final UnauthorizedHandler onUnauthorized;

  Future<dynamic> get(String path, {bool authenticated = true}) {
    return _send(method: 'GET', path: path, authenticated: authenticated);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      authenticated: authenticated,
    );
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
      authenticated: authenticated,
    );
  }

  Future<dynamic> delete(String path, {bool authenticated = true}) {
    return _send(method: 'DELETE', path: path, authenticated: authenticated);
  }

  Future<http.Response> getRaw(String path, {bool authenticated = true}) async {
    final uri = _buildUri(path);
    final response = await client.get(
      uri,
      headers: _headers(authenticated: authenticated),
    );

    if (response.statusCode == 401 && authenticated) {
      final refreshed = await refreshSession();
      if (refreshed) {
        return client.get(uri, headers: _headers(authenticated: authenticated));
      }
      await onUnauthorized();
    }

    _ensureSuccess(response);
    return response;
  }

  Future<dynamic> multipart(
    String path, {
    required Map<String, String> fields,
    required PlatformFile file,
    String fileField = 'audioFile',
  }) async {
    return _sendMultipart(
      path: path,
      fields: fields,
      file: file,
      fileField: fileField,
      retried: false,
    );
  }

  Future<dynamic> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    required bool authenticated,
    bool retried = false,
  }) async {
    final uri = _buildUri(path);
    final response = await _request(
      method: method,
      uri: uri,
      body: body,
      authenticated: authenticated,
    );

    if (response.statusCode == 401 && authenticated && !retried) {
      final refreshed = await refreshSession();
      if (refreshed) {
        return _send(
          method: method,
          path: path,
          body: body,
          authenticated: authenticated,
          retried: true,
        );
      }
      await onUnauthorized();
    }

    _ensureSuccess(response);
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> _sendMultipart({
    required String path,
    required Map<String, String> fields,
    required PlatformFile file,
    required String fileField,
    required bool retried,
  }) async {
    final request = http.MultipartRequest('POST', _buildUri(path));
    request.headers.addAll(_headers(authenticated: true));
    request.fields.addAll(fields);
    request.files.add(await _buildMultipartFile(fileField, file));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401 && !retried) {
      final refreshed = await refreshSession();
      if (refreshed) {
        return _sendMultipart(
          path: path,
          fields: fields,
          file: file,
          fileField: fileField,
          retried: true,
        );
      }
      await onUnauthorized();
    }

    _ensureSuccess(response);
    return jsonDecode(response.body);
  }

  Future<http.Response> _request({
    required String method,
    required Uri uri,
    Map<String, dynamic>? body,
    required bool authenticated,
  }) {
    final headers = _headers(authenticated: authenticated);

    switch (method) {
      case 'GET':
        return client.get(uri, headers: headers);
      case 'POST':
        return client.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      case 'PATCH':
        return client.patch(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      case 'DELETE':
        return client.delete(uri, headers: headers);
      default:
        throw UnsupportedError('Unsupported method $method');
    }
  }

  Map<String, String> _headers({required bool authenticated}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = accessTokenProvider();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _buildUri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String code = 'request_failed';
    String message = 'Request failed';

    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final error = data['error'];
        if (error is Map<String, dynamic>) {
          code = error['code']?.toString() ?? code;
          message = error['message']?.toString() ?? message;
        }
      } catch (_) {
        message = response.body;
      }
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: code,
      message: message,
    );
  }

  Future<http.MultipartFile> _buildMultipartFile(
    String field,
    PlatformFile file,
  ) async {
    final mediaType = _mediaType(file.name);
    if (file.bytes != null) {
      return http.MultipartFile.fromBytes(
        field,
        file.bytes!,
        filename: file.name,
        contentType: mediaType,
      );
    }

    if (file.path != null) {
      return http.MultipartFile.fromPath(
        field,
        file.path!,
        filename: file.name,
        contentType: mediaType,
      );
    }

    throw ApiException(
      statusCode: 422,
      code: 'invalid_file',
      message: 'No se pudo leer el archivo seleccionado',
    );
  }

  MediaType _mediaType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.wav')) {
      return MediaType('audio', 'wav');
    }
    if (lower.endsWith('.ogg')) {
      return MediaType('audio', 'ogg');
    }
    return MediaType('audio', 'mpeg');
  }
}
