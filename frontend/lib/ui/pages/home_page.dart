import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../providers/schedule_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("CalBot Web"),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(title: const Text("Theme Settings"), content: const ThemeSettingsPanel()),
              );
            },
          ),
        ],
      ),
      body: SfCalendar(
        view: CalendarView.month,
        allowedViews: allowedViews,
        dataSource: _ScheduleDataSource(schedules),
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
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
