import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

import '../../api/api_config.dart';
import '../../api/api_requester.dart';
import '../../models/user_model.dart';
import '../home_controller.dart';

class AuthController extends GetxController {
  final box = GetStorage();
  final _apiRequester = ApiRequester();

  final isGuest = false.obs;
  final isLoggedIn = false.obs;
  final userEmail = ''.obs;
  final userToken = ''.obs;
  final userUid = ''.obs;
  final userGid = ''.obs;
  final errorMessage = ''.obs;

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
    final savedGuest = box.read('isGuest') as bool?;
    final savedUserEmail = box.read('userEmail') as String?;
    final savedToken = box.read('userToken') as String?;
    final savedUserUid = box.read('userUid') as String?;
    final savedUserGid = box.read('userGid') as String?;

    if (savedGuest != null && savedGuest) {
      isGuest.value = true;
    }

    if (savedUserEmail != null && savedUserEmail.isNotEmpty) {
      isLoggedIn.value = true;
      userEmail.value = savedUserEmail;
      userToken.value = savedToken ?? '';
      userUid.value = savedUserUid ?? '';
      userGid.value = savedUserGid ?? '';
    }
  }

  Future<void> handleGuestLogin() async {
    isLoading.value = true;

    final uuid = Uuid().v4().replaceAll('-', '').substring(0, 10);
    final String email = uuid.toLowerCase();
    final String password = 'pwd_$email';

    try {
      isGuest.value = true;
      await signup(email, password);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleLogin() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

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

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
    emailController.clear();
    passwordController.clear();
  }

  Future<void> login(String email, String password) async {
    final Map<String, dynamic> responseData;

    try {
      responseData = await _apiRequester.post(endpoint: '', body: {'email': email, 'password': password});
    } catch (e) {
      //_handleAuthError(e, 'Login');
      return;
    }

    final int statusCode = responseData['status'];
    final String message = responseData['message'] ?? '';
    final Map<String, dynamic>? data = responseData['data'] as Map<String, dynamic>?;

    if (statusCode == 200 && data != null) {
      final token = data['token'] as String? ?? '';
      final user = data['user'] as Map<String, dynamic>?;

      if (user != null) {
        final userEmail = user['email'] as String? ?? email;
        final uid = user['uid'] as String? ?? '';
        final gid = user['gid'] as String? ?? '';

        _saveUserSession(userEmail, token, uid, gid);

        // Close any open dialogs first, then close auth dialog
        Get.until((route) => !Get.isDialogOpen!);

        // Show success message
        Get.snackbar(
          'Success',
          'Welcome back!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        errorMessage.value = 'Invalid response format';
        Get.defaultDialog(
          title: 'Error',
          middleText: errorMessage.value,
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () {
            if (Get.isDialogOpen!) Get.back(); // Only close error dialog
          },
        );
      }
    } else {
      errorMessage.value = message.isNotEmpty ? message : 'Login failed';
      Get.defaultDialog(
        title: 'Error',
        middleText: errorMessage.value,
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () {
          if (Get.isDialogOpen!) Get.back(); // Only close error dialog
        },
      );
    }
  }

  Future<void> signup(String email, String password) async {
    final Map<String, dynamic> responseData;

    try {
      responseData = await _apiRequester.post(endpoint: ApiConfig.authRegister, body: {'email': email, 'password': password});
    } catch (e) {
      final Map<String, String> errorInfo = _apiRequester.handleApiError(e, 'Registration');
      final String title = errorInfo['title'] ?? 'Error';
      final String message = errorInfo['message'] ?? 'An unknown error occurred';

      Get.defaultDialog(
        title: title,
        middleText: message,
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () {
          if (Get.isDialogOpen!) Get.back();
        },
      );

      return;
    }

    final int statusCode = responseData['status'] ?? 0;

    if (statusCode == 201) {
      final Map<String, dynamic>? userJson = responseData['data'] as Map<String, dynamic>?;

      if (userJson == null) {
        Get.defaultDialog(
          title: 'Error',
          middleText: 'Cannot read user data',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () {
            if (Get.isDialogOpen!) Get.back();
          },
        );
        return;
      }

      try {
        UserModel userData = UserModel.fromJson(responseData['data']);
        _saveUserSession(userData.email, userData.token, userData.uid, userData.gid);

        Get.until((route) => !Get.isDialogOpen!);

        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        Get.defaultDialog(
          title: 'Error',
          middleText: 'Failed to parse user data: $e',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () {
            if (Get.isDialogOpen!) Get.back();
          },
        );
      }
    } else {
      debugPrint('❌ Signup failed [Status $statusCode]: ${responseData['message']}');
      String errorMessage = "Registration failed";

      if (statusCode == 400) {
        errorMessage = 'Email already in use';
      }

      Get.defaultDialog(
        title: 'Error',
        middleText: errorMessage,
        textConfirm: 'Try again',
        confirmTextColor: Colors.white,
        onConfirm: () {
          if (Get.isDialogOpen!) Get.back();
        },
      );
    }
  }

  void _saveUserSession(String email, String token, String uid, String gid) {
    userEmail.value = email;
    userToken.value = token;
    userUid.value = uid;
    userGid.value = gid;

    if (isGuest.value) {
      box.write('isGuest', true);
    } else {
      box.remove('isGuest');
    }

    box.write('userEmail', email);
    box.write('userToken', token);
    box.write('userUid', uid);
    box.write('userGid', gid);

    isLoggedIn.value = true;

    emailController.clear();
    passwordController.clear();

    debugPrint('✅ User session saved: uid=$uid, gid=$gid, email=$email');
  }

  void logout() {
    isLoggedIn.value = false;
    isGuest.value = false;

    userEmail.value = '';
    userToken.value = '';
    userUid.value = '';
    userGid.value = '';

    box.remove('isGuest');
    box.remove('userEmail');
    box.remove('userToken');
    box.remove('userUid');
    box.remove('userGid');

    emailController.clear();
    passwordController.clear();
    isLogin.value = true;
    isLoading.value = false;
    errorMessage.value = '';
  }

  /// Logout and show auth dialog (like first login)
  void logoutAndShowAuthDialog() {
    // Close drawer first
    Get.back();

    // Perform logout
    logout();

    // Clear schedules from HomeController
    try {
      final homeController = Get.find<HomeController>();
      homeController.scheduleList.clear();
    } catch (e) {
      debugPrint('HomeController not found: $e');
    }

    // Show success message
    Get.snackbar(
      'Logged Out',
      'You have been successfully logged out',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Show auth dialog after a short delay
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   Get.dialog(const AuthDialog(), barrierDismissible: false);
    // });
  }
}
