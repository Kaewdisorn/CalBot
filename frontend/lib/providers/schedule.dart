import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/schedule.dart'; // Make sure this now has Appointment helpers

// CalendarController provider
final calendarControllerProvider = Provider<CalendarController>((ref) {
  final controller = CalendarController();
  controller.view = CalendarView.month;
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Notifier to manage list of Appointments
class ScheduleNotifier extends Notifier<List<Appointment>> {
  @override
  List<Appointment> build() {
    final now = DateTime.now();

    // Sample Appointment using createAppointment helper
    final sampleAppointment = createAppointment(
      eventName: 'Sample Event',
      location: '',
      startDate: DateTime(now.year, now.month, now.day),
      startTime: TimeOfDay(hour: 11, minute: 0),
      endDate: DateTime(now.year, now.month, now.day),
      endTime: TimeOfDay(hour: 11, minute: 5),
      background: const Color(0xFF0F8644),
      isAllDay: false,
      description: '',
      isDone: false,
    );

    return [sampleAppointment];
  }

  void addAppointment(Appointment appointment) {
    state = [...state, appointment];
  }

  void removeAppointment(Appointment appointment) {
    state = state.where((a) => a != appointment).toList();
  }

  void clearAppointments() {
    state = [];
  }

  void toggleDone(int index) {
    final appt = state[index];
    Map<String, dynamic> data = {};
    if (appt.notes != null) {
      data = jsonDecode(appt.notes!);
    }
    data['isDone'] = !(data['isDone'] ?? false);
    appt.notes = jsonEncode(data);
    state = [...state]; // trigger update
  }
}

// NotifierProvider for list of appointments
final scheduleListProvider = NotifierProvider<ScheduleNotifier, List<Appointment>>(ScheduleNotifier.new);

/// CalendarDataSource provider
final calendarDataSourceProvider = Provider<ScheduleDataSource>((ref) {
  final appointments = ref.watch(scheduleListProvider);
  return ScheduleDataSource(appointments);
});
