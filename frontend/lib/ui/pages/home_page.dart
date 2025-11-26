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

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Image.asset('assets/images/halulu.png', width: 36, height: 36), const SizedBox(width: 8), const Text("Halulu")]),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              ThemeSettingsPanel.show(context);
            },
          ),
        ],
      ),
      body: SfCalendar(
        view: CalendarView.month,
        showDatePickerButton: true,
        showNavigationArrow: true,
        showTodayButton: true,
        allowedViews: allowedViews,
        headerStyle: CalendarHeaderStyle(
          backgroundColor: seedColor.withOpacity(0.05), // subtle bg
          textStyle: TextStyle(color: seedColor, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.start,
        ),
        dataSource: ScheduleDataSource(schedules), // now Appointment-based
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final selectedDate = details.date!;
            showDialog(
              context: context,
              builder: (_) => AddScheduleDialog(date: selectedDate),
            );
          } else if (details.targetElement == CalendarElement.appointment) {
            // Appointments are now Appointment objects
            final appointment = details.appointments!.first as Appointment;

            // Optional: convert Appointment back to Schedule if needed
            final schedule = Schedule(
              id: appointment.id?.toString() ?? '',
              title: appointment.subject,
              startDate: appointment.startTime,
              endDate: appointment.endTime,
              description: appointment.notes,
              color: appointment.color,
              recurrenceRule: appointment.recurrenceRule,
              isDone: appointment.color == Colors.grey, // example mapping
            );

            showDialog(
              context: context,
              builder: (_) => ScheduleDetailDialog(schedule: schedule),
            );
          }
        },
      ),
    );
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> schedules) {
    // Convert your Schedule objects to Appointment objects
    appointments = schedules.map((s) => s.toAppointment()).toList();
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String? getRecurrenceRule(int index) {
    return appointments![index].recurrenceRule;
  }
}
