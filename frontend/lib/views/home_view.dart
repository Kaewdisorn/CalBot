import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../controllers/home_controller.dart';
import '../models/schedule_model.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/schedule_detail.dart';
import 'widgets/settings_drawer.dart';

class HomeView extends StatelessWidget {
  final homeController = Get.find<HomeController>();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleJson = [
      {
        'id': '1',
        'title': 'Team Meeting',
        'start': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        'end': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
        'recurrenceRule': 'FREQ=DAILY;INTERVAL=1;COUNT=10',
        'exceptionDateList': [DateTime(2025, 12, 05).toIso8601String()],
        'colorValue': 0xFF42A5F5,
      },
      {
        'id': '2',
        'title': 'Client Call',
        'start': DateTime.now().add(Duration(days: 1, hours: 3)).toIso8601String(),
        'end': DateTime.now().add(Duration(days: 1, hours: 4)).toIso8601String(),
        'colorValue': 0xFF66BB6A,
      },
      {
        'id': '3',
        'title': 'Shopping',
        'start': DateTime.now().add(Duration(days: 1, hours: 3)).toIso8601String(),
        'end': DateTime.now().add(Duration(days: 2, hours: 4)).toIso8601String(),
        'colorValue': 0xFF66BB6A,
      },
    ];

    final sampleData = sampleJson.map<ScheduleModel>((j) => ScheduleModel.fromJson(j)).toList();

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
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment) {
            final Appointment tappedAppointment = details.appointments![0];
            print(details.date);
            print(tappedAppointment.startTime);

            showDialog(
              context: context,
              builder: (context) => ScheduleDetailPopup(appointment: tappedAppointment, onEdit: () {}, onDelete: () {}),
            );
          }
        },
        // appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
        //   print(details);
        //   return Container();
        // },
      ),
    );
  }
}

class ScheduuleDataSource extends CalendarDataSource {
  ScheduuleDataSource(List<ScheduleModel> models) {
    appointments = models.map((e) => e.toCalendarAppointment()).toList();
  }
}
