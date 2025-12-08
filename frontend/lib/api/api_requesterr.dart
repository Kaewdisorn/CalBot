import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiRequester {
  Future<Map<String, dynamic>> post({required String endpoint, required Map<String, dynamic> body}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      debugPrint('📡 POST: $url');
      debugPrint('📦 Body: ${jsonEncode(body)}');
      final response = await http.post(url, headers: ApiConfig.defaultHeaders, body: jsonEncode(body)).timeout(ApiConfig.connectionTimeout);
      debugPrint('✅ Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        debugPrint('❌ Error Response [${response.statusCode}]: ${response.body}');
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('❌ POST Error: $e');
      throw Exception('Failed to make POST request: $e');
    }
  }
}
