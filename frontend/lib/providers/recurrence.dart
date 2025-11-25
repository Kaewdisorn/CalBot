// providers/recurrence.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recurrence.dart';

class RecurrenceNotifier extends Notifier<RecurrenceModel> {
  @override
  RecurrenceModel build() {
    return RecurrenceModel.none(); // default
  }

  void setType(RecurrenceType type) {
    state = state.copyWith(type: type, weekdays: type == RecurrenceType.weekly ? [] : null);
  }

  void setInterval(int interval) {
    state = state.copyWith(interval: interval);
  }

  void toggleWeekday(int day) {
    if (state.weekdays == null) return;
    final newWeekdays = [...state.weekdays!];
    if (newWeekdays.contains(day)) {
      newWeekdays.remove(day);
    } else {
      newWeekdays.add(day);
    }
    state = state.copyWith(weekdays: newWeekdays);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }
}

final recurrenceProvider = NotifierProvider<RecurrenceNotifier, RecurrenceModel>(RecurrenceNotifier.new);
