import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../api/api_config.dart';
import '../../api/api_requester.dart';

class AuthController extends GetxController {
  final box = GetStorage();
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
    final Map<String, dynamic>? userData = responseData['data'] as Map<String, dynamic>?;

    if (statusCode == 201 && userData != null) {
      // Extract token and user data
      final token = userData['token'] as String? ?? '';
      final user = userData['user'] as Map<String, dynamic>?;

      if (user != null) {
        final userEmail = user['email'] as String? ?? email;
        final uid = user['uid'] as String? ?? '';
        final gid = user['gid'] as String? ?? '';

        _saveUserSession(userEmail, token, uid, gid);

        Get.until((route) => !Get.isDialogOpen!);

        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.defaultDialog(
          title: 'Error',
          middleText: 'Cannot read user data',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () {
            if (Get.isDialogOpen!) Get.back();
          },
        );
      }
    } else {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Registration failed',
        textConfirm: 'try again',
        confirmTextColor: Colors.white,
        onConfirm: () {
          if (Get.isDialogOpen!) Get.back();
        },
      );
    }
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
}
