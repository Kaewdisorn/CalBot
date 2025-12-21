import 'package:get/get_connect/connect.dart';
import 'package:halulu/core/configs/api_config.dart';

class AuthProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConfig.baseUrl;
    httpClient.timeout = ApiConfig.connectionTimeout;
  }

  Future register(Map<String, dynamic> requestBody) async {
    // final response = await post(ApiConfig.authRegister, requestBody, headers: ApiConfig.defaultHeaders);
    // return response;
    return {
      'isSuccess': true,
      'message': 'User registered successfully',
      'data': {
        'gid': 'd60356d7-a262-4a28-b5d2-e9ec97809b03',
        'uid': 'd60356d7-a262-4a28-b5d2-e9ec97809b03',
        'userName': requestBody['userName'],
        'userEmail': '1766177343035@guest.com',
        'token': 'mock-jwt-token',
        'refreshToken': 'mock-refresh-token',
        'createdAt': '2024-06-20T12:15:43.511Z',
        'updatedAt': '2024-06-20T12:15:43.511Z',
      },
    };
  }
}
