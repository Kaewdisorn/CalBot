import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Riverpod Notifier for MVC Controller
final calendarControllerProvider = NotifierProvider<CalendarController, List<Appointment>>(CalendarController.new);

class CalendarController extends Notifier<List<Appointment>> {
  @override
  List<Appointment> build() {
    return [
      CalendarEvent(title: "Test Event", start: DateTime.now(), end: DateTime.now().add(const Duration(hours: 1)), color: Colors.blue).toAppointment(),
      CalendarEvent(
        title: "Another Event",
        start: DateTime.now().add(const Duration(days: 1)),
        end: DateTime.now().add(const Duration(days: 1, hours: 2)),
        color: Colors.red,
      ).toAppointment(),
    ];
  }

  void addEvent(CalendarEvent event) {
    state = [...state, event.toAppointment()];
  }

  void removeEvent(CalendarEvent event) {
    state = state.where((e) => e.subject != event.title || e.startTime != event.start).toList();
  }
}
