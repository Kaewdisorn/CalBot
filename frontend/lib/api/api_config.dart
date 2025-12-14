import 'package:flutter/foundation.dart';

class ApiConfig {
  static const Map<String, String> defaultHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json'};
  static const Duration connectionTimeout = Duration(seconds: 30);

  static String get baseUrl {
    const compileTime = String.fromEnvironment('BASE_URL', defaultValue: '');
    if (compileTime.isNotEmpty) return compileTime;

    if (kReleaseMode) return 'https://halulu-project.onrender.com';
    return 'http://localhost:30001';
  }

  static const String authRegister = '/api/auth/register';

  static const String scheduleUrl = '/api/schedules';
}
