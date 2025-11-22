import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../controllers/meeting.dart';
import '../models/meeting.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetings = ref.watch(meetingProvider);

    return Scaffold(
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: MeetingDataSource(meetings),
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example: Add a new meeting dynamically
          final DateTime now = DateTime.now();
          ref.read(meetingProvider.notifier).addMeeting(Meeting('New Meeting', now, now.add(const Duration(hours: 1)), Colors.blue, false));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Calendar data source mapping
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => _getMeeting(index).from;

  @override
  DateTime getEndTime(int index) => _getMeeting(index).to;

  @override
  String getSubject(int index) => _getMeeting(index).eventName;

  @override
  Color getColor(int index) => _getMeeting(index).background;

  @override
  bool isAllDay(int index) => _getMeeting(index).isAllDay;

  Meeting _getMeeting(int index) => appointments![index] as Meeting;
}
