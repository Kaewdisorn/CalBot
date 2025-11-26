import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/schedule_provider.dart';

class ScheduleCalendar extends ConsumerWidget {
  const ScheduleCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(scheduleProvider);

    return SfCalendar(
      view: CalendarView.month,
      dataSource: _ScheduleDataSource(schedules),
      monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    );
  }
}

class _ScheduleDataSource extends CalendarDataSource {
  _ScheduleDataSource(List schedules) {
    appointments = schedules;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].date;

  @override
  DateTime getEndTime(int index) => appointments![index].date;

  @override
  String getSubject(int index) => appointments![index].title;

  @override
  Color getColor(int index) => Colors.blue;
}
