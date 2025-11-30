import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final box = GetStorage();
  final isLoggedIn = false.obs;
  final isGuest = false.obs;
  final userName = ''.obs;

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
    final savedIsGuest = box.read('isGuest') as bool? ?? false;

    if (savedUserName != null && savedUserName.isNotEmpty) {
      isLoggedIn.value = true;
      userName.value = savedUserName;
    } else if (savedIsGuest) {
      isGuest.value = true;
    }
  }

  void handleLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    isLoading.value = true;

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 1), () {
      if (isLogin.value) {
        login(email, password);
      } else {
        signup(email, password);
      }
      // Do not call Navigator.pop/Get.back() here — the view uses the controller's state to hide the dialog overlay.
      isLoading.value = false;
    });
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

  void login(String email, String password) {
    // Implement actual API login call
    // For now, just save the user info
    userName.value = email;
    box.write('userName', email);
    box.write('isGuest', false);
    isLoggedIn.value = true;
    isGuest.value = false;
  }

  void signup(String email, String password) {
    // Implement actual API signup call
    userName.value = email;
    box.write('userName', email);
    box.write('isGuest', false);
    isLoggedIn.value = true;
    isGuest.value = false;
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
    box.remove('userName');
    box.remove('isGuest');
  }
}
