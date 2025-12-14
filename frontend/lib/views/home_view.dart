import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../controllers/home_controller.dart';
import '../controllers/widgets_controller/auth_controller.dart';
import '../controllers/widgets_controller/setting_controller.dart';
import '../models/schedule_model.dart';
import 'widgets/auth_dialog.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/schedule_form_dialog.dart';
import 'widgets/settings_drawer.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final homeController = Get.find<HomeController>();
  final settingController = Get.find<SettingsController>();
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: CustomAppBar(
          toolbarHeight: 60,
          titleText: 'Halulu',
          logoAsset: 'assets/images/halulu_128x128.png',
          appbarColor: settingController.selectedColor.value,
          welcomeUsername: authController.isLoggedIn.value ? (authController.isGuest.value ? 'Guest' : authController.userEmail.value) : null,
        ),
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
                headerStyle: CalendarHeaderStyle(backgroundColor: settingController.selectedColor.value.withAlpha(1)),
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode: homeController.isAgendaView.value ? MonthAppointmentDisplayMode.indicator : MonthAppointmentDisplayMode.appointment,
                  showAgenda: homeController.isAgendaView.value,
                ),
                appointmentBuilder: (context, calendarAppointmentDetails) {
                  final Appointment appointment = calendarAppointmentDetails.appointments.first as Appointment;
                  final noteData = ScheduleModel.parseNoteData(appointment.notes);
                  final bool isRecurring = appointment.recurrenceRule != null && appointment.recurrenceRule!.isNotEmpty;
                  final bool isDone = isRecurring ? noteData.isOccurrenceDone(appointment.startTime) : noteData.isDone;
                  final Color displayColor = isDone ? Colors.grey : appointment.color;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: displayColor, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      appointment.subject,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                        decorationColor: Colors.white,
                        decorationThickness: 2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
                onTap: (CalendarTapDetails details) async {
                  final appts = details.appointments;

                  if (details.targetElement == CalendarElement.appointment && appts != null && appts.isNotEmpty) {
                    final Appointment tappedAppointment = appts[0] as Appointment;
                    final existingSchedule = homeController.scheduleList.firstWhereOrNull((s) => s.uid == tappedAppointment.id);

                    if (existingSchedule != null) {
                      final DateTime? tappedOccurrenceDate = existingSchedule.isRecurring ? tappedAppointment.startTime : null;

                      showDialog(
                        context: context,
                        builder: (context) => ScheduleFormDialog(
                          existingSchedule: existingSchedule,
                          tappedOccurrenceDate: tappedOccurrenceDate,
                          onSave: (updatedSchedule) async {
                            final success = await homeController.updateSchedule(updatedSchedule);
                            if (success) {
                              Get.snackbar(
                                'Success',
                                'Schedule "${updatedSchedule.title}" updated!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                              );
                            }
                          },
                          onDelete: () async {
                            final success = await homeController.deleteSchedule(existingSchedule.uid);
                            if (success) {
                              Get.snackbar(
                                'Deleted',
                                'Schedule "${existingSchedule.title}" deleted!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                              );
                            }
                          },
                          onDeleteSingle: (occurrenceDate) async {
                            // Delete single occurrence by adding it to exception dates
                            final index = homeController.scheduleList.indexWhere((s) => s.uid == existingSchedule.uid);
                            if (index != -1) {
                              final schedule = homeController.scheduleList[index];
                              // Normalize the date
                              final normalizedDate = DateTime(occurrenceDate.year, occurrenceDate.month, occurrenceDate.day);
                              // Add to exception list
                              final List<DateTime> newExceptionDates = [...(schedule.exceptionDateList ?? <DateTime>[]), normalizedDate];
                              // Create updated schedule with new exception date
                              final updatedSchedule = ScheduleModel(
                                gid: schedule.gid,
                                uid: schedule.uid,
                                title: schedule.title,
                                start: schedule.start,
                                end: schedule.end,
                                isAllDay: schedule.isAllDay,
                                note: schedule.note,
                                location: schedule.location,
                                colorValue: schedule.colorValue,
                                recurrenceRule: schedule.recurrenceRule,
                                exceptionDateList: newExceptionDates,
                                isDone: schedule.isDone,
                                doneOccurrences: schedule.doneOccurrences,
                              );
                              // Call API to update
                              await homeController.updateSchedule(updatedSchedule);
                            }
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
                        onSave: (newSchedule) async {
                          // Call API to create schedule
                          final success = await homeController.createSchedule(newSchedule);
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'Schedule "${newSchedule.title}" created!',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        },
                      ),
                    );
                  }
                },
              );
            }),

            // Auth overlay: dim background + centered dialog
            Obx(() {
              if (!authController.isLoggedIn.value) {
                return Stack(
                  children: [
                    const ModalBarrier(color: Colors.black54, dismissible: false),
                    Center(
                      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: const AuthDialog()),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<ScheduleModel> models) {
    appointments = models.map((e) => e.toCalendarAppointment()).toList();
  }
}
