import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:halulu/api/api_requesterr.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';

class AuthController extends GetxController {
  final box = GetStorage();
  final _apiClient = ApiClient();
  final _apiRequester = ApiRequester();

  final isLoggedIn = false.obs;
  final isGuest = false.obs;
  final userName = ''.obs;
  final userToken = ''.obs;
  final userId = ''.obs; // User uid from backend
  final userGid = ''.obs; // User gid from backend
  final errorMessage = ''.obs;

  // Dialog-specific state
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLogin = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _checkAuthStatus() {
    // Check if user was previously logged in or using guest mode
    final savedUserName = box.read('userName') as String?;
    final savedToken = box.read('userToken') as String?;
    final savedUserId = box.read('userId') as String?;
    final savedUserGid = box.read('userGid') as String?;
    final savedIsGuest = box.read('isGuest') as bool? ?? false;

    if (savedUserName != null && savedUserName.isNotEmpty) {
      isLoggedIn.value = true;
      userName.value = savedUserName;
      userToken.value = savedToken ?? '';
      userId.value = savedUserId ?? '';
      userGid.value = savedUserGid ?? '';
    } else if (savedIsGuest) {
      isGuest.value = true;
    }
  }

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Please fill in all fields',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return;
    }

    // Basic email validation
    if (!GetUtils.isEmail(email)) {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Please enter a valid email',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return;
    }

    // Basic password validation
    if (password.length < 6) {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Password must be at least 6 characters',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (isLogin.value) {
        await login(email, password);
      } else {
        await signup(email, password);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void handleGuest() {
    useAsGuest();
    // Dialog overlay will hide via controller state; no Navigator.pop here.
  }

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
    emailController.clear();
    passwordController.clear();
  }

  Future<void> login(String email, String password) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.authLogin,
      body: {'email': email, 'password': password},
      parser: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      final token = data['token'] as String? ?? '';
      final user = data['user'] as Map<String, dynamic>?;

      if (user != null) {
        final userEmail = user['email'] as String? ?? email;
        final uid = user['uid'] as String? ?? '';
        final gid = user['gid'] as String? ?? '';

        _saveUserSession(userEmail, token, uid, gid);
        Get.defaultDialog(title: 'Success', middleText: 'Welcome back!', textConfirm: 'OK', confirmTextColor: Colors.white, onConfirm: () => Get.back());
      } else {
        errorMessage.value = 'Invalid response format';
        Get.defaultDialog(title: 'Error', middleText: errorMessage.value, textConfirm: 'OK', confirmTextColor: Colors.white, onConfirm: () => Get.back());
      }
    } else {
      errorMessage.value = response.error ?? 'Login failed';
      Get.defaultDialog(title: 'Error', middleText: errorMessage.value, textConfirm: 'OK', confirmTextColor: Colors.white, onConfirm: () => Get.back());
    }
  }

  Future<void> signup(String email, String password) async {
    final Map<String, dynamic> userData = await _apiRequester.post(endpoint: ApiConfig.authRegister, body: {'email': email, 'password': password});
    print(userData);
    final int statusCode = userData['status'];
    final String message = userData['message'] ?? '';

    if (statusCode == 201) {
      Get.defaultDialog(
        title: 'Success',
        middleText: 'Account created successfully!',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } else {
      Get.defaultDialog(title: 'Error', middleText: message, textConfirm: 'OK', confirmTextColor: Colors.white, onConfirm: () => Get.back());
    }
    // final response = await _apiClient.post<Map<String, dynamic>>(
    //   ApiConfig.authRegister,
    //   body: {'email': email, 'password': password},
    //   parser: (json) => json as Map<String, dynamic>,
    // );

    // if (response.isSuccess && response.data != null) {
    //   final data = response.data!;
    //   final token = data['token'] as String? ?? '';
    //   final user = data['user'] as Map<String, dynamic>?;

    //   if (user != null) {
    //     final userEmail = user['email'] as String? ?? email;
    //     final uid = user['uid'] as String? ?? '';
    //     final gid = user['gid'] as String? ?? '';

    //     _saveUserSession(userEmail, token, uid, gid);
    //     Get.defaultDialog(
    //       title: 'Success',
    //       middleText: 'Account created successfully!\n\nUser ID: $uid',
    //       textConfirm: 'OK',
    //       confirmTextColor: Colors.white,
    //       onConfirm: () => Get.back(),
    //     );
    //   } else {
    //     errorMessage.value = 'Invalid response format';
    //     Get.defaultDialog(title: 'Error', middleText: errorMessage.value, textConfirm: 'OK', confirmTextColor: Colors.white, onConfirm: () => Get.back());
    //   }
    // } else {
    //   errorMessage.value = response.error ?? 'Registration failed';
    //   Get.defaultDialog(title: 'Error', middleText: errorMessage.value, textConfirm: 'OK', confirmTextColor: Colors.white, onConfirm: () => Get.back());
    // }
  }

  void _saveUserSession(String email, String token, String uid, String gid) {
    userName.value = email;
    userToken.value = token;
    userId.value = uid;
    userGid.value = gid;

    box.write('userName', email);
    box.write('userToken', token);
    box.write('userId', uid);
    box.write('userGid', gid);
    box.write('isGuest', false);

    isLoggedIn.value = true;
    isGuest.value = false;

    // Clear form
    emailController.clear();
    passwordController.clear();

    debugPrint('✅ User session saved: uid=$uid, gid=$gid, email=$email');
  }

  void useAsGuest() {
    box.write('isGuest', true);
    box.remove('userName');
    isGuest.value = true;
    isLoggedIn.value = false;
  }

  void logout() {
    isLoggedIn.value = false;
    isGuest.value = false;
    userName.value = '';
    userToken.value = '';
    userId.value = '';
    userGid.value = '';

    box.remove('userName');
    box.remove('userToken');
    box.remove('userId');
    box.remove('userGid');
    box.remove('isGuest');
  }

  /// Get auth headers for authenticated API calls
  Map<String, String> get authHeaders => ApiConfig.authHeaders(userToken.value);
}
