import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final box = GetStorage();
  final RxBool isPasswordVisible = false.obs;
  final RxString username = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final cacheUserName = box.read('userName');

    if (cacheUserName != null) {
      username.value = cacheUserName;
    }
  }

  void guestLogin() {
    username.value = 'Guest';
    box.write('userName', 'Guest');
    Get.offAllNamed(Routes.HOME);
  }
}
