import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controllers/widgets_controller/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/widgets_controller/setting_controller.dart';
import 'views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  final box = GetStorage();
  final savedColorSeed = box.read('colorSeed') as int? ?? Colors.blue.toARGB32();

  Get.put(AuthController());
  Get.put(HomeController());
  Get.put(SettingsController());

  runApp(MyApp(colorSeedValue: savedColorSeed));
}

class MyApp extends StatelessWidget {
  final int colorSeedValue;

  const MyApp({super.key, required this.colorSeedValue});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: HomeView(),
      theme: ThemeData(colorSchemeSeed: Color(colorSeedValue), brightness: Brightness.light, useMaterial3: true),
      debugShowCheckedModeBanner: false,
    );
  }
}
