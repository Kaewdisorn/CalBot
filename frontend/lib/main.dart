import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(const CalBotApp());
}

class CalBotApp extends StatelessWidget {
  const CalBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'CalBot Test Calendar', home: const CalendarTestPage());
  }
}

class CalendarTestPage extends StatelessWidget {
  const CalendarTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Syncfusion Calendar Test')),
      body: SfCalendar(view: CalendarView.month, monthViewSettings: const MonthViewSettings(showAgenda: true), dataSource: EventDataSource(_getTestEvents())),
    );
  }

  List<Appointment> _getTestEvents() {
    return <Appointment>[
      Appointment(startTime: DateTime.now(), endTime: DateTime.now().add(const Duration(hours: 1)), subject: 'Test Event', color: Colors.blue),
      Appointment(
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        subject: 'Another Event',
        color: Colors.red,
      ),
    ];
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}
