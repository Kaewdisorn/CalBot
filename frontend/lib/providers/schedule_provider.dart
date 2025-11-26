import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule.dart';

class ScheduleNotifier extends Notifier<List<Schedule>> {
  @override
  List<Schedule> build() {
    return [Schedule(id: '1', title: 'Team Meeting', date: DateTime(2025, 1, 10)), Schedule(id: '2', title: 'Dinner with Jane', date: DateTime(2025, 1, 12))];
  }

  void addSchedule(Schedule s) {
    state = [...state, s];
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, List<Schedule>>(ScheduleNotifier.new);
