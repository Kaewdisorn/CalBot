import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final _authController = Get.find<AuthController>();

  String get displayName => _authController.username;
}
