import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/schedule.dart';

final calendarControllerProvider = Provider<CalendarController>((ref) {
  final controller = CalendarController();
  controller.view = CalendarView.month;
  ref.onDispose(() => controller.dispose());
  return controller;
});

class ScheduleNotifier extends Notifier<List<Schedule>> {
  @override
  List<Schedule> build() {
    // Add one sample schedule
    final now = DateTime.now();
    final sampleSchedule = Schedule(
      'Sample Event',
      '',
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day, 11, 0),
      const Color(0xFF0F8644),
      false,
    );
    return [sampleSchedule];
  }

  void addSchedule(Schedule schedule) {
    state = [...state, schedule];
  }

  void removeSchedule(Schedule schedule) {
    state = state.where((s) => s != schedule).toList();
  }

  void clearSchedules() {
    state = [];
  }
}

// NotifierProvider
final scheduleListProvider = NotifierProvider<ScheduleNotifier, List<Schedule>>(ScheduleNotifier.new);

// CalendarDataSource provider
final calendarDataSourceProvider = Provider<ScheduleDataSource>((ref) {
  final schedules = ref.watch(scheduleListProvider);
  return ScheduleDataSource(schedules);
});
