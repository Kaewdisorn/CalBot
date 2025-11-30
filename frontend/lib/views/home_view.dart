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
    return Scaffold(
      appBar: CustomAppBar(toolbarHeight: 60, titleText: 'Halulu', logoAsset: 'assets/images/halulu_128x128.png'),

      endDrawer: const SettingsDrawer(),

      body: Obx(() {
        // recreate data source from current schedule list so calendar updates
        final dataSource = ScheduleDataSource(homeController.scheduleList.toList());
        return SfCalendar(
          view: CalendarView.month,
          showDatePickerButton: true,
          showNavigationArrow: true,
          showTodayButton: true,
          allowedViews: homeController.allowedViews,
          dataSource: dataSource,
          monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
          onTap: (CalendarTapDetails details) async {
            // appointment tapped
            final appts = details.appointments;
            if (details.targetElement == CalendarElement.appointment && appts != null && appts.isNotEmpty) {
              final Appointment tappedAppointment = appts[0] as Appointment;
              // show detail popup
              showDialog(
                context: context,
                builder: (context) => ScheduleDetailPopup(appointment: tappedAppointment, onEdit: () {}, onDelete: () {}),
              );
              return;
            }

            // empty cell tapped -> prompt to add
            if (details.targetElement == CalendarElement.calendarCell || details.targetElement == CalendarElement.agenda) {
              final DateTime? tapped = details.date;
              if (tapped == null) return;

              final titleController = TextEditingController();
              final result = await showDialog<String?>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add event'),
                  content: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.of(context).pop(titleController.text.trim()), child: const Text('Add')),
                  ],
                ),
              );

              if (result != null && result.isNotEmpty) {
                final newId = DateTime.now().millisecondsSinceEpoch.toString();
                final newModel = ScheduleModel(id: newId, title: result, start: tapped, end: tapped.add(const Duration(hours: 1)), isAllDay: false);

                homeController.scheduleList.add(newModel);
              }
            }
          },
        );
      }),
    );
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<ScheduleModel> models) {
    appointments = models.map((e) => e.toCalendarAppointment()).toList();
  }
}
