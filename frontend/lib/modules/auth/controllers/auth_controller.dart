import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final box = GetStorage();
  final RxBool isPasswordVisible = false.obs;

  //User data
  String userName = '';
  String userEmail = '';

  @override
  void onInit() {
    super.onInit();
    final cacheUserName = box.read('userName');

    if (cacheUserName != null) {
      userName = cacheUserName;
    }
  }

  void guestLogin() {
    userName = 'Guest';
    box.write('userName', 'Guest');
    Get.offAllNamed(Routes.HOME);
  }
}
