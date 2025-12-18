import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/custom_appbar.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  static const logoImgPath = 'assets/images/halulu_128x128.png';
  static const headerTitle = 'Halulu';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(toolbarHeight: 60, titleText: headerTitle, logoAsset: logoImgPath, appbarColor: null, welcomeUsername: 'test'),
      endDrawer: null,
    );
  }
}
