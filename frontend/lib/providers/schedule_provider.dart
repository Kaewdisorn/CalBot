import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule.dart';

class ScheduleNotifier extends Notifier<List<Schedule>> {
  @override
  List<Schedule> build() {
    // Sample schedules
    return [
      Schedule(
        id: '1',
        title: 'Team Meeting',
        startDate: DateTime(2025, 1, 10, 10, 0),
        endDate: DateTime(2025, 1, 10, 11, 0),
        color: const Color(0xFF42A5F5), // blue
        isDone: false,
      ),
      Schedule(
        id: '2',
        title: 'Dinner with Jane',
        startDate: DateTime(2025, 1, 12, 19, 0),
        endDate: DateTime(2025, 1, 12, 21, 0),
        color: const Color(0xFFEF5350), // red
        isDone: false,
      ),
    ];
  }

  void addSchedule(Schedule schedule) {
    state = [...state, schedule];
  }

  void updateSchedule(Schedule schedule) {
    state = [
      for (final s in state)
        if (s.id == schedule.id) schedule else s,
    ];
  }

  void removeSchedule(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, List<Schedule>>(ScheduleNotifier.new);
