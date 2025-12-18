import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/views/home_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.REGISTER, page: () => RegisterView(), binding: AuthBinding()),
    GetPage(name: Routes.LOGIN, page: () => LoginView(), binding: AuthBinding()),
    GetPage(name: Routes.HOME, page: () => HomeView(), binding: HomeBinding(), transition: Transition.noTransition),
  ];
}
