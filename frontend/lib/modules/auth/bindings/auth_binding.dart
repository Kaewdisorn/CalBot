import 'package:get/get.dart';
import 'package:halulu/data/repositories/auth_repository.dart';
import 'package:halulu/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
