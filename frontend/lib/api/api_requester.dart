import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halulu/core/configs/api_config.dart';
import 'package:http/http.dart' as http;

class ApiRequester {
  Future<Map<String, dynamic>> post({required String endpoint, required Map<String, dynamic> body}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      debugPrint('📡 POST: $url');
      debugPrint('📦 Body: ${jsonEncode(body)}');

      final response = await http.post(url, headers: ApiConfig.defaultHeaders, body: jsonEncode(body)).timeout(ApiConfig.connectionTimeout);

      debugPrint('✅ Response [${response.statusCode}]: ${response.body}');

      // Try to parse response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return responseData;
    } on TimeoutException catch (e) {
      // Re-throw TimeoutException to preserve error type
      debugPrint('❌ POST Timeout: $e');
      rethrow;
    } on SocketException catch (e) {
      // Re-throw SocketException (no internet/server offline)
      debugPrint('❌ POST Network Error: $e');
      rethrow;
    } on http.ClientException catch (e) {
      // Re-throw ClientException (connection refused, network issues)
      debugPrint('❌ POST Client Error: $e');
      rethrow;
    } on HttpException catch (e) {
      // Re-throw HttpException (server errors)
      debugPrint('❌ POST HTTP Error: $e');
      rethrow;
    } on FormatException catch (e) {
      // JSON parsing error
      debugPrint('❌ POST JSON Parse Error: $e');
      throw FormatException('Invalid response format from server: $e');
    } catch (e) {
      // Other errors - wrap in generic exception
      debugPrint('❌ POST Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get({required String endpoint}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      debugPrint('📡 GET: $url');

      final response = await http.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      debugPrint('✅ Response [${response.statusCode}]: ${response.body}');

      // Try to parse response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Add status code to response data for easier handling
      return {'status': response.statusCode, ...responseData};
    } on TimeoutException catch (e) {
      debugPrint('❌ GET Timeout: $e');
      rethrow;
    } on SocketException catch (e) {
      debugPrint('❌ GET Network Error: $e');
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('❌ GET Client Error: $e');
      rethrow;
    } on HttpException catch (e) {
      debugPrint('❌ GET HTTP Error: $e');
      rethrow;
    } on FormatException catch (e) {
      debugPrint('❌ GET JSON Parse Error: $e');
      throw FormatException('Invalid response format from server: $e');
    } catch (e) {
      debugPrint('❌ GET Error: $e');
      rethrow;
    }
  }

  Map<String, String> handleApiError(dynamic error, String operation) {
    String title;
    String message;

    if (error is TimeoutException) {
      title = 'Connection Timeout';
      message = 'Server is not responding. Please check your internet connection and try again.';
    } else if (error is SocketException) {
      title = 'No Internet Connection';
      message = 'Please check your internet connection and try again.';
    } else if (error is http.ClientException) {
      title = 'Connection Failed';
      message = 'Unable to connect to the server. Please try again.';
    } else if (error is HttpException) {
      title = 'Server Error';
      message = 'The server is currently unavailable. Please try again later.';
    } else {
      title = '$operation Failed';
      message = 'An unexpected error occurred. Please try again.\n\nError: ${error.toString()}';
    }

    return {'title': title, 'message': message};
  }
}
