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
              // Custom appointment builder to show strikethrough for done items
              appointmentBuilder: (context, calendarAppointmentDetails) {
                final Appointment appointment = calendarAppointmentDetails.appointments.first as Appointment;
                final noteData = ScheduleModel.parseNoteData(appointment.notes);

                // For recurring events, check if this specific occurrence is done
                // For non-recurring events, check the isDone flag
                final bool isRecurring = appointment.recurrenceRule != null && appointment.recurrenceRule!.isNotEmpty;
                final bool isDone = isRecurring ? noteData.isOccurrenceDone(appointment.startTime) : noteData.isDone;

                // Apply gray color for done occurrences
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
                // appointment tapped
                final appts = details.appointments;

                // Existing schedule tapped -> open edit popup
                if (details.targetElement == CalendarElement.appointment && appts != null && appts.isNotEmpty) {
                  final Appointment tappedAppointment = appts[0] as Appointment;

                  // Find the matching ScheduleModel
                  final existingSchedule = homeController.scheduleList.firstWhereOrNull((s) => s.id == tappedAppointment.id);

                  if (existingSchedule != null) {
                    // For recurring events, pass the tapped occurrence date
                    final DateTime? tappedOccurrenceDate = existingSchedule.isRecurring ? tappedAppointment.startTime : null;

                    showDialog(
                      context: context,
                      builder: (context) => ScheduleFormDialog(
                        existingSchedule: existingSchedule,
                        tappedOccurrenceDate: tappedOccurrenceDate, // Pass the occurrence date
                        onSave: (updatedSchedule) {
                          // Update the schedule in the list
                          final index = homeController.scheduleList.indexWhere((s) => s.id == updatedSchedule.id);
                          if (index != -1) {
                            homeController.scheduleList[index] = updatedSchedule;
                          }
                        },
                        onDelete: () {
                          // Remove the entire schedule series from the list
                          homeController.scheduleList.removeWhere((s) => s.id == existingSchedule.id);
                        },
                        onDeleteSingle: (occurrenceDate) {
                          // Delete single occurrence by adding it to exception dates
                          final index = homeController.scheduleList.indexWhere((s) => s.id == existingSchedule.id);
                          if (index != -1) {
                            final schedule = homeController.scheduleList[index];
                            // Normalize the date
                            final normalizedDate = DateTime(occurrenceDate.year, occurrenceDate.month, occurrenceDate.day);
                            // Add to exception list
                            final List<DateTime> newExceptionDates = [...(schedule.exceptionDateList ?? <DateTime>[]), normalizedDate];
                            // Create updated schedule with new exception date
                            homeController.scheduleList[index] = ScheduleModel(
                              id: schedule.id,
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
