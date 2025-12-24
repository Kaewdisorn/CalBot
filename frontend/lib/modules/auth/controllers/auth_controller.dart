import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:halulu/core/widgets/show_alert_snackbar.dart';
import 'package:halulu/data/models/user_model.dart';
import 'package:halulu/data/repositories/auth_repository.dart';
import 'package:halulu/routes/app_routes.dart';
import 'package:uuid/uuid.dart';

class AuthController extends GetxController {
  final String logoImgPath = 'assets/images/halulu_128x128.png';

  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final box = GetStorage();
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // TextEditingControllers
  final userNameController = TextEditingController();
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final userConfirmPasswordController = TextEditingController();

  //User data
  String userName = '';

  @override
  void onReady() {
    super.onReady();
    _checkLoginStatus();
  }

  /* ------------------ */
  /* Guest Registration */
  /* ------------------ */
  Future<void> registerGuest() async {
    final DateTime now = DateTime.now().toLocal();

    String userEmail = '${now.millisecondsSinceEpoch}@guest.com';
    String userPassword = Uuid().v4().toLowerCase();

    UserModel userModel = await _authRepository.register(userName: userName, userEmail: userEmail, userPassword: userPassword);

    _saveUserCache(userModel);
    Get.offAllNamed(Routes.HOME);
  }

  /* ----------------- */
  /* User Registration */
  /* ----------------- */
  Future<void> registerUser() async {
    _validateRegistrationInputs();

    UserModel userModel = await _authRepository.register(
      userName: userNameController.text.trim(),
      userEmail: userEmailController.text.trim(),
      userPassword: Uuid().v5(Namespace.url.value, userPasswordController.text.toString()),
    );

    _saveUserCache(userModel);
    Get.offAllNamed(Routes.HOME);
  }

  /* ---------- */
  /* Save Cache */
  /* ---------- */
  void _saveUserCache(UserModel userModel) {
    userName = userModel.userName ?? '';

    box.write('gid', userModel.gid);
    box.write('uid', userModel.uid);
    box.write('userName', userModel.userName);
    box.write('userEmail', userModel.userEmail);
  }

  /* ------------------ */
  /* Check login status */
  /* ------------------ */
  void _checkLoginStatus() {
    final cacheGid = box.read('gid');
    final cacheUid = box.read('uid');
    final cacheUserName = box.read('userName');
    final cacheUserEmail = box.read('userEmail');

    if (cacheGid != null && cacheUid != null && cacheUserEmail != null && cacheUserName != null) {
      userName = cacheUserName;
      Get.offAllNamed(Routes.HOME);
    }
  }

  /* ------------------------------ */
  /* Validation Registration Inputs */
  /* ------------------------------ */
  void _validateRegistrationInputs() {
    if (userNameController.text.trim().isEmpty) {
      AppSnackbar.error(title: 'Registration Error', message: 'Username cannot be empty.');
      return;
    }

    if (userEmailController.text.trim().isEmpty) {
      AppSnackbar.error(title: 'Registration Error', message: 'Email cannot be empty.');
      return;
    }

    if (userPasswordController.text.isEmpty) {
      AppSnackbar.error(title: 'Registration Error', message: 'Password cannot be empty.');
      return;
    }

    if (userConfirmPasswordController.text.isEmpty) {
      AppSnackbar.error(title: 'Registration Error', message: 'Confirm Password cannot be empty.');
      return;
    }

    if (userPasswordController.text != userConfirmPasswordController.text) {
      AppSnackbar.error(title: 'Registration Error', message: 'Passwords do not match.');
      return;
    }
  }
}
