import 'package:flutter/material.dart';
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
      'Sample Event', // eventName
      '', // location
      DateTime(now.year, now.month, now.day), // startDate
      TimeOfDay(hour: 11, minute: 0), // startTime (TimeOfDay)
      DateTime(now.year, now.month, now.day),
      TimeOfDay(hour: 11, minute: 5),
      DateTime(now.year, now.month, now.day, 12, 0), // to (end DateTime)
      const Color(0xFF0F8644), // background
      false, // isAllDay
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
