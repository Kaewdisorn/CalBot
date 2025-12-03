/// API Configuration
/// Centralized configuration for all API-related settings
class ApiConfig {
  // ============ Base URLs ============
  // Change this based on your environment
  static const String baseUrl = 'http://localhost:3000';

  // For production, you might use:
  // static const String baseUrl = 'https://api.calbot.com';

  // ============ API Endpoints ============
  static const String schedules = '/api/schedules';
  static const String health = '/api/health';

  // ============ Timeouts ============
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Headers ============
  static Map<String, String> get defaultHeaders => {'Content-Type': 'application/json', 'Accept': 'application/json'};

  // Add auth header when needed
  static Map<String, String> authHeaders(String token) => {...defaultHeaders, 'Authorization': 'Bearer $token'};
}
