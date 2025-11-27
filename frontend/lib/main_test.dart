import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Calendar Test',
      home: MyApp(), // Your actual app widget
      localizationsDelegates: [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: const [
        Locale('en', 'US'),
        // add other locales if needed
      ],
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();

    // Add a recurring appointment
    _appointments = [
      Appointment(
        id: 'rec1',
        startTime: DateTime(2025, 1, 1, 9, 0),
        endTime: DateTime(2025, 1, 1, 10, 0),
        subject: 'Daily Meeting',
        color: Colors.blue,
        recurrenceRule: 'FREQ=DAILY;COUNT=7',
        recurrenceExceptionDates: [],
      ),
    ];
  }

  void _onTapAppointment(CalendarTapDetails details) async {
    if (details.appointments == null || details.appointments!.isEmpty) return;
    final Appointment appt = details.appointments!.first;
    final DateTime? occurrenceDate = details.date;

    // Show dialog to delete
    final answer = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text('Delete only this occurrence or the entire series?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'one'), child: const Text('Only This')),
          TextButton(onPressed: () => Navigator.pop(context, 'all'), child: const Text('Entire Series')),
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
        ],
      ),
    );

    if (answer == 'one' && occurrenceDate != null) {
      // Add the occurrence date to exceptions
      setState(() {
        final updated = Appointment(
          id: appt.id,
          startTime: appt.startTime,
          endTime: appt.endTime,
          subject: appt.subject,
          color: appt.color,
          recurrenceRule: appt.recurrenceRule,
          recurrenceExceptionDates: List<DateTime>.from(appt.recurrenceExceptionDates ?? [])..add(occurrenceDate),
        );

        // Replace old appointment
        _appointments = [updated, ..._appointments.where((a) => a.id != appt.id)];
      });
    } else if (answer == 'all') {
      // Remove the series
      setState(() {
        _appointments.removeWhere((a) => a.id == appt.id);
      });
    }
  }

  void _addRecurringAppointment() {
    final newAppt = Appointment(
      id: 'rec${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime(2025, 1, 5, 14, 0),
      endTime: DateTime(2025, 1, 5, 15, 0),
      subject: 'Weekly Sync',
      color: Colors.green,
      recurrenceRule: 'FREQ=WEEKLY;COUNT=5',
      recurrenceExceptionDates: [],
    );

    setState(() {
      _appointments.add(newAppt);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Syncfusion Calendar Recurring Example'),
          actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addRecurringAppointment)],
        ),
        body: SfCalendar(
          view: CalendarView.month,
          dataSource: AppointmentDataSource(_appointments),
          onTap: _onTapAppointment,
          monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        ),
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
