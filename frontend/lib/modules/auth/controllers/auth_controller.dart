import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:halulu/data/models/user_model.dart';
import 'package:halulu/data/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final box = GetStorage();
  final RxBool isPasswordVisible = false.obs;

  //User data
  String userName = '';
  String userEmail = '';
  String userPassword = '';

  @override
  void onInit() {
    super.onInit();
    final cacheUserName = box.read('userName');

    if (cacheUserName != null) {
      userName = cacheUserName;
    }
  }

  void registerGuest() {
    final DateTime now = DateTime.now().toLocal();
    userName = 'Guest';
    userEmail = '${now.millisecondsSinceEpoch}@guest.com';
    userPassword = Uuid().v4();

    UserModel userModel = _authRepository.register(userName: userName, userEmail: userEmail, userPassword: userPassword);

    _saveUserCache();
    Get.offAllNamed(Routes.HOME);
  }

  void _saveUserCache() {
    box.write('userName', userName);
    box.write('userEmail', userEmail);
  }
}
