import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/home_controller.dart';
import 'controllers/widgets_controller/setting_controller.dart';
import 'views/home_view.dart';

void main() {
  Get.put(HomeController());
  Get.put(SettingsController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(home: HomeView(), debugShowCheckedModeBanner: false);
  }
}
