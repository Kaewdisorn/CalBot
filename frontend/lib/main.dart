// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// import 'controllers/widgets_controller/auth_controller.dart';
// import 'controllers/home_controller.dart';
// import 'controllers/widgets_controller/setting_controller.dart';
// import 'views/home_view.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();

//   final box = GetStorage();
//   final savedColorSeed = box.read('colorSeed') as int? ?? Colors.blue.toARGB32();

//   Get.put(AuthController());
//   Get.put(HomeController());
//   Get.put(SettingsController());

//   runApp(MyApp(colorSeedValue: savedColorSeed));
// }

// class MyApp extends StatelessWidget {
//   final int colorSeedValue;

//   const MyApp({super.key, required this.colorSeedValue});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       home: HomeView(),
//       theme: ThemeData(colorSchemeSeed: Color(colorSeedValue), brightness: Brightness.light, useMaterial3: true),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await GetStorage.init();

  final box = GetStorage();
  final savedColorSeed = box.read('colorSeed') as int? ?? Colors.blue.toARGB32();

  runApp(CalBot(colorSeedValue: savedColorSeed));
}

class CalBot extends StatelessWidget {
  final int colorSeedValue;

  const CalBot({super.key, required this.colorSeedValue});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CalBot Halulu',
      theme: ThemeData(colorSchemeSeed: Color(colorSeedValue), brightness: Brightness.light, useMaterial3: true),
      initialRoute: Routes.LOGIN,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
