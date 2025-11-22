import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';

// Use Notifier instead of StateNotifier
class MeetingController extends Notifier<List<Event>> {
  @override
  List<Event> build() {
    // Initial state
    final today = DateTime.now();
    final startTime = DateTime(today.year, today.month, today.day, 9);
    final endTime = startTime.add(const Duration(hours: 2));
    return [Event('Conference', startTime, endTime, const Color(0xFF0F8644), false)];
  }

  void addEvent(Event meeting) {
    state = [...state, meeting];
  }
}

// Provider
final eventProvider = NotifierProvider<MeetingController, List<Event>>(() => MeetingController());
