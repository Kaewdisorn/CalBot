import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/add_schedule_dialog.dart';
import '../widgets/schedule_detail_dialog.dart';
import '../widgets/theme_settings_panel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const allowedViews = [
    CalendarView.day,
    CalendarView.week,
    CalendarView.workWeek,
    CalendarView.timelineDay,
    CalendarView.timelineWeek,
    CalendarView.timelineWorkWeek,
    CalendarView.month,
    CalendarView.schedule,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(scheduleProvider);
    final theme = ref.watch(themeProvider);
    final seedColor = theme.seedColor ?? Theme.of(context).colorScheme.primary;

    // Create a calendar data source with colors updated based on isDone
    final calendarDataSource = ScheduleDataSource(
      schedules.map((s) {
        // Automatically grey out "done" schedules
        return s.copyWith(color: s.isDone ? Colors.grey : s.color ?? seedColor);
      }).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Image.asset('assets/images/halulu.png', width: 36, height: 36), const SizedBox(width: 8), const Text("Halulu")]),
        actions: [IconButton(icon: const Icon(Icons.color_lens), onPressed: () => ThemeSettingsPanel.show(context))],
      ),
      body: SfCalendar(
        view: CalendarView.month,
        showDatePickerButton: true,
        showNavigationArrow: true,
        showTodayButton: true,
        allowedViews: allowedViews,
        headerStyle: CalendarHeaderStyle(
          backgroundColor: seedColor.withAlpha(10),
          textStyle: TextStyle(color: seedColor, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.start,
        ),
        dataSource: calendarDataSource,
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        onTap: (details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final selectedDate = details.date!;
            showDialog(
              context: context,
              builder: (_) => AddScheduleDialog(date: selectedDate),
            );
          } else if (details.targetElement == CalendarElement.appointment) {
            final appointment = details.appointments!.first as Appointment;

            // Safe lookup of Schedule with orElse
            final schedule = schedules.firstWhere(
              (s) => s.id == appointment.id?.toString(),
              orElse: () => Schedule(
                id: appointment.id?.toString() ?? '',
                title: appointment.subject,
                startDate: appointment.startTime,
                endDate: appointment.endTime,
                description: appointment.notes,
                color: appointment.color,
                recurrenceRule: appointment.recurrenceRule,
                isDone: appointment.color == Colors.grey,
              ),
            );

            showDialog(
              context: context,
              builder: (_) => ScheduleDetailDialog(schedule: schedule),
            ).then((_) {
              // Refresh calendar after possible change
              calendarDataSource.updateAppointments(
                ref.read(scheduleProvider).map((s) {
                  return s.copyWith(color: s.isDone ? Colors.grey : s.color ?? seedColor);
                }).toList(),
              );
            });
          }
        },
      ),
    );
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> schedules) {
    appointments = schedules.map((s) => s.toAppointment()).toList();
  }

  /// Update appointments and refresh calendar
  void updateAppointments(List<Schedule> schedules) {
    appointments = schedules.map((s) => s.toAppointment()).toList();
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => appointments![index].subject;

  @override
  Color getColor(int index) => appointments![index].color;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String? getRecurrenceRule(int index) => appointments![index].recurrenceRule;
}
