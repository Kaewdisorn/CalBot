import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halulu/core/widgets/custom_appbar.dart';
import 'package:halulu/modules/home/controllers/home_controller.dart';
import 'package:halulu/modules/home/views/drawer_view.dart';

class HomeView extends GetView<HomeController> {
  static const logoImgPath = 'assets/images/halulu_128x128.png';
  static const headerTitle = 'Halulu';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(toolbarHeight: 60, titleText: headerTitle, logoAsset: logoImgPath, appbarColor: null, welcomeUsername: controller.displayName),
      endDrawer: const DrawerView(),
    );
  }
}
