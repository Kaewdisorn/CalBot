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
  }
}
