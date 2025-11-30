import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final box = GetStorage();
  final isLoggedIn = false.obs;
  final isGuest = false.obs;
  final userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
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
