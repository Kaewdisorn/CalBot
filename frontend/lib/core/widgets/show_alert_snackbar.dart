import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void error({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 4),
    );
  }
}
