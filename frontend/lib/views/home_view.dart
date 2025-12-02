import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../controllers/home_controller.dart';
import '../controllers/widgets_controller/setting_controller.dart';
import '../models/schedule_model.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/schedule_form_dialog.dart';
import 'widgets/settings_drawer.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final homeController = Get.find<HomeController>();
  final settingController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    final headerColor = settingController.selectedColor.value;

    return Scaffold(
      appBar: CustomAppBar(toolbarHeight: 60, titleText: 'Halulu', logoAsset: 'assets/images/halulu_128x128.png', appbarColor: headerColor),
      endDrawer: const SettingsDrawer(),
      body: Stack(
        children: [
          Obx(() {
            final dataSource = ScheduleDataSource(homeController.scheduleList.toList());

            return SfCalendar(
              view: CalendarView.month,
              showDatePickerButton: true,
              showNavigationArrow: true,
              showTodayButton: true,
              allowedViews: homeController.allowedViews,
              dataSource: dataSource,
              headerStyle: CalendarHeaderStyle(backgroundColor: headerColor.withAlpha(1)),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: homeController.isAgendaView.value ? MonthAppointmentDisplayMode.indicator : MonthAppointmentDisplayMode.appointment,
                showAgenda: homeController.isAgendaView.value,
              ),
              onTap: (CalendarTapDetails details) async {
                // appointment tapped
                final appts = details.appointments;

                // Existing schedule tapped -> open edit popup
                if (details.targetElement == CalendarElement.appointment && appts != null && appts.isNotEmpty) {
                  final Appointment tappedAppointment = appts[0] as Appointment;

                  // Find the matching ScheduleModel
                  final existingSchedule = homeController.scheduleList.firstWhereOrNull((s) => s.id == tappedAppointment.id);

                  if (existingSchedule != null) {
                    showDialog(
                      context: context,
                      builder: (context) => ScheduleFormDialog(
                        existingSchedule: existingSchedule,
                        onSave: (updatedSchedule) {
                          // Update the schedule in the list
                          final index = homeController.scheduleList.indexWhere((s) => s.id == updatedSchedule.id);
                          if (index != -1) {
                            homeController.scheduleList[index] = updatedSchedule;
                          }
                        },
                        onDelete: () {
                          // Remove the schedule from the list
                          homeController.scheduleList.removeWhere((s) => s.id == existingSchedule.id);
                        },
                      ),
                    );
                  }
                  return;
                }

                // Disable "add event" popup when in agenda view
                if (homeController.isAgendaView.value) {
                  return;
                }

                // Empty cell tapped -> open add popup
                if (details.targetElement == CalendarElement.calendarCell || details.targetElement == CalendarElement.agenda) {
                  final DateTime? tapped = details.date;
                  if (tapped == null) return;

                  showDialog(
                    context: context,
                    builder: (context) => ScheduleFormDialog(
                      initialDate: tapped,
                      onSave: (newSchedule) {
                        homeController.scheduleList.add(newSchedule);
                      },
                    ),
                  );
                }
              },
            );
          }),

          // Auth overlay: dim background + centered dialog
          // Obx(() {
          //   if (!Get.find<AuthController>().isLoggedIn.value && !Get.find<AuthController>().isGuest.value) {
          //     return Stack(
          //       children: [
          //         const ModalBarrier(color: Colors.black54, dismissible: false),
          //         Center(
          //           child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: const AuthDialog()),
          //         ),
          //       ],
          //     );
          //   }
          //   return const SizedBox.shrink();
          // }),
        ],
      ),
    );
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<ScheduleModel> models) {
    appointments = models.map((e) => e.toCalendarAppointment()).toList();
  }
}
