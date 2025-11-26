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
          backgroundColor: seedColor.withValues(alpha: 0.01),
          textStyle: TextStyle(color: seedColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        dataSource: _ScheduleDataSource(schedules),
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final selectedDate = details.date!;
            showDialog(
              context: context,
              builder: (_) => AddScheduleDialog(date: selectedDate),
            );
          } else if (details.targetElement == CalendarElement.appointment) {
            final appointment = details.appointments!.first as Schedule;
            showDialog(
              context: context,
              builder: (_) => ScheduleDetailDialog(schedule: appointment),
            );
          }
        },
      ),
    );
  }
}

class _ScheduleDataSource extends CalendarDataSource {
  _ScheduleDataSource(List schedules) {
    appointments = schedules;
  }

  @override
  DateTime getStartTime(int index) {
    final item = appointments![index];
    return item.date; // Your model’s date
  }

  @override
  DateTime getEndTime(int index) {
    final item = appointments![index];
    return item.date.add(const Duration(hours: 1)); // <-- duration for calendar
  }

  @override
  String getSubject(int index) {
    final item = appointments![index];
    return item.title;
  }

  @override
  Color getColor(int index) {
    return Colors.blue;
  }
}
