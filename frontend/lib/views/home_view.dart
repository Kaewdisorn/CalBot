import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../controllers/home_controller.dart';
import '../widgets/custom_appbar.dart'; // <-- import your AppBar widget

class HomeView extends StatelessWidget {
  final controller = Get.put(HomeController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        toolbarHeight: 60,
        onSettingsTap: () {
          // Handle settings tap here
          debugPrint("Settings tapped!");
        },
      ),
      body: SfCalendar(view: CalendarView.month),
    );
  }
}
