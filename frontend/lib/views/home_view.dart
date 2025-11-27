import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../controllers/home_controller.dart';
import '../models/schedule_model.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/settings_drawer.dart';

class HomeView extends StatelessWidget {
  final homeController = Get.find<HomeController>();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate fetching from API
    final sampleData = [
      ScheduleModel(id: '1', title: 'Team Meeting', start: DateTime.now().add(Duration(hours: 1)), end: DateTime.now().add(Duration(hours: 2))),
      ScheduleModel(
        id: '2',
        title: 'Client Call',
        start: DateTime.now().add(Duration(days: 1, hours: 3)),
        end: DateTime.now().add(Duration(days: 1, hours: 4)),
      ),
    ];
    return Scaffold(
      appBar: CustomAppBar(toolbarHeight: 60, titleText: 'Halulu', logoAsset: 'assets/images/halulu_128x128.png'),

      endDrawer: const SettingsDrawer(),

      body: SfCalendar(
        view: CalendarView.month,
        showDatePickerButton: true,
        showNavigationArrow: true,
        showTodayButton: true,
        allowedViews: homeController.allowedViews,
        dataSource: ScheduuleDataSource(sampleData),
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      ),
    );
  }
}

class ScheduuleDataSource extends CalendarDataSource {
  ScheduuleDataSource(List<ScheduleModel> models) {
    appointments = models.map((e) => e.toCalendarAppointment()).toList();
  }
}
