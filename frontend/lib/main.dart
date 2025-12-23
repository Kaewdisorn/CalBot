import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'modules/auth/bindings/auth_binding.dart';
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
      initialBinding: AuthBinding(),
      title: 'CalBot Halulu',
      theme: ThemeData(colorSchemeSeed: Color(colorSeedValue), brightness: Brightness.light, useMaterial3: true),
      initialRoute: Routes.LOGIN,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
