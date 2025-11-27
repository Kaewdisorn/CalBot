import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../controllers/home_controller.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/settings_drawer.dart';

class HomeView extends StatelessWidget {
  final controller = Get.put(HomeController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(toolbarHeight: 60, titleText: 'Halulu', logoAsset: 'assets/images/halulu_128x128.png'),

      endDrawer: const SettingsDrawer(),

      body: SfCalendar(view: CalendarView.month),
    );
  }
}
