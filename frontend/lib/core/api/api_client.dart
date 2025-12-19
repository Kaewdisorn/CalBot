import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:halulu/core/configs/api_config.dart';
import 'package:http/http.dart' as http;

import 'api_response.dart';

/// HTTP Client wrapper for making API calls
/// Handles all HTTP operations with error handling and response parsing
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // ============ GET Request ============
  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, String>? headers, T Function(dynamic json)? parser}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      debugPrint('📡 GET: $url');

      final response = await _client.get(url, headers: headers ?? ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, parser);
    } catch (e) {
      debugPrint('❌ GET Error: $e');
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  // ============ POST Request ============
  Future<ApiResponse<T>> post<T>(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers, T Function(dynamic json)? parser}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      debugPrint('📡 POST: $url');
      debugPrint('📦 Body: ${jsonEncode(body)}');

      final response = await _client
          .post(url, headers: headers ?? ApiConfig.defaultHeaders, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, parser);
    } catch (e) {
      debugPrint('❌ POST Error: $e');
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  // ============ PUT Request ============
  Future<ApiResponse<T>> put<T>(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers, T Function(dynamic json)? parser}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      debugPrint('📡 PUT: $url');
      debugPrint('📦 Body: ${jsonEncode(body)}');

      final response = await _client
          .put(url, headers: headers ?? ApiConfig.defaultHeaders, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, parser);
    } catch (e) {
      debugPrint('❌ PUT Error: $e');
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  // ============ DELETE Request ============
  Future<ApiResponse<T>> delete<T>(String endpoint, {Map<String, String>? headers, T Function(dynamic json)? parser}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      debugPrint('📡 DELETE: $url');

      final response = await _client.delete(url, headers: headers ?? ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, parser);
    } catch (e) {
      debugPrint('❌ DELETE Error: $e');
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  // ============ Response Handler ============
  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(dynamic json)? parser) {
    debugPrint('📥 Status: ${response.statusCode}');
    debugPrint('📥 Body: ${response.body}');

    // Success range: 200-299
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null as T);
      }

      final jsonData = jsonDecode(response.body);

      // If parser provided, use it to convert JSON to model
      if (parser != null) {
        final data = parser(jsonData);
        return ApiResponse.success(data);
      }

      return ApiResponse.success(jsonData as T);
    }

    // Error responses
    String errorMessage;
    try {
      final errorJson = jsonDecode(response.body);
      errorMessage = errorJson['message'] ?? errorJson['error'] ?? 'Unknown error';
    } catch (_) {
      errorMessage = response.body.isNotEmpty ? response.body : 'Request failed';
    }

    return ApiResponse.error(errorMessage, statusCode: response.statusCode);
  }

  // ============ Error Message Helper ============
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out';
    }
    if (error.toString().contains('HandshakeException')) {
      return 'SSL/TLS error';
    }
    return error.toString();
  }

  // ============ Cleanup ============
  void dispose() {
    _client.close();
  }
}
