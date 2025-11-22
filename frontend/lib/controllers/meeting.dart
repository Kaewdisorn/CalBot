import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meeting.dart';

// Use Notifier instead of StateNotifier
class MeetingController extends Notifier<List<Meeting>> {
  @override
  List<Meeting> build() {
    // Initial state
    final today = DateTime.now();
    final startTime = DateTime(today.year, today.month, today.day, 9);
    final endTime = startTime.add(const Duration(hours: 2));
    return [Meeting('Conference', startTime, endTime, const Color(0xFF0F8644), false)];
  }

  // Add a new meeting
  void addMeeting(Meeting meeting) {
    state = [...state, meeting];
  }
}

// Provider
final meetingProvider = NotifierProvider<MeetingController, List<Meeting>>(() => MeetingController());
