import 'package:get/get.dart';
import 'package:halulu/modules/home/controllers/drawer_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DrawerController>(() => DrawerController());
  }
}
