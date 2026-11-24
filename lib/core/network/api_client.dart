import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:savefood/core/constants/api_constants.dart';
import 'package:savefood/core/network/token_storage.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await TokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint, {bool auth = false}) async {
    final response = await _client
        .get(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: await _headers(auth: auth),
        )
        .timeout(ApiConstants.timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: await _headers(auth: auth),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConstants.timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final response = await _client
        .put(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: await _headers(auth: auth),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConstants.timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final response = await _client
        .patch(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: await _headers(auth: auth),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConstants.timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint,
      {bool auth = false}) async {
    final response = await _client
        .delete(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: await _headers(auth: auth),
        )
        .timeout(ApiConstants.timeout);

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] ?? 'An error occurred';

    if (response.statusCode == 401) {
      throw ApiException('Unauthorized: $message', 401);
    } else if (response.statusCode == 422) {
      final errors = body['errors'] as Map<String, dynamic>?;
      final firstError = errors?.values.first;
      final errorMsg =
          firstError is List ? firstError.first.toString() : message;
      throw ApiException(errorMsg, 422);
    } else if (response.statusCode == 403) {
      throw ApiException('Forbidden: $message', 403);
    } else {
      throw ApiException(message, response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
