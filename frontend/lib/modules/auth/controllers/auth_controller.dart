import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final RxBool isPasswordVisible = false.obs;
  String username = '';

  void guestLogin() {
    username = 'Guest';
    Get.offAllNamed(Routes.HOME);
  }
}
