import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/custom_appbar.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(toolbarHeight: 60, titleText: 'Halulu', logoAsset: 'assets/images/halulu_128x128.png', appbarColor: null, welcomeUsername: 'test'),
    );
  }
}
