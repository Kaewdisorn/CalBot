import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recurring Appointments',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Recurring Appointment'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, textAlign: TextAlign.center)),
      body: SfCalendar(
        view: CalendarView.week,
        allowedViews: const [CalendarView.month, CalendarView.day, CalendarView.week, CalendarView.workWeek, CalendarView.schedule],
        dataSource: _getCalendarDataSource(),
      ),
    );
  }

  _AppointmentDataSource _getCalendarDataSource() {
    final List<Appointment> appointments = <Appointment>[];
    final DateTime exceptionDate = DateTime(2021, 04, 14);

    appointments.add(
      Appointment(
        recurrenceId: 01,
        startTime: DateTime(2021, 04, 14, 13),
        endTime: DateTime(2021, 04, 14, 14),
        subject: 'Scrum meeting - Changed Occurrence',
        color: Colors.greenAccent,
      ),
    );

    appointments.add(
      Appointment(
        startTime: DateTime(2019, 01, 1, 09),
        endTime: DateTime(2019, 01, 1, 10),
        subject: 'Daily recurring meeting',
        color: Colors.blue,
        recurrenceRule: "FREQ=DAILY;INTERVAL=1;COUNT=10",
      ),
    );

    appointments.add(
      Appointment(
        startTime: DateTime(2019, 02, 1, 10),
        endTime: DateTime(2019, 02, 1, 11),
        subject: 'Weekly Meeting',
        color: Colors.brown,
        recurrenceRule: "FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE;COUNT=10",
      ),
    );

    appointments.add(
      Appointment(
        startTime: DateTime(2019, 02, 1, 11),
        endTime: DateTime(2019, 02, 1, 12),
        subject: 'Monthly Meeting',
        color: Colors.indigo,
        recurrenceRule: "FREQ=MONTHLY;BYMONTHDAY=3;INTERVAL=1;COUNT=10",
      ),
    );

    appointments.add(
      Appointment(
        startTime: DateTime(2019, 02, 1, 10),
        endTime: DateTime(2019, 02, 1, 11),
        subject: 'Yearly Meeting',
        color: Colors.green,
        recurrenceRule: "FREQ=YEARLY;BYMONTHDAY=16;BYMONTH=6;INTERVAL=1;COUNT=10",
      ),
    );

    appointments.add(
      Appointment(
        startTime: DateTime(2019, 12, 16, 10),
        endTime: DateTime(2019, 12, 16, 12),
        subject: 'Meeting',
        color: Colors.blue,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=2;COUNT=10',
      ),
    );

    DateTime exceptionDate1 = DateTime(2019, 12, 20);
    appointments.add(
      Appointment(
        startTime: DateTime(2019, 12, 16, 10),
        endTime: DateTime(2019, 12, 16, 12),
        subject: 'Occurs daily',
        color: Colors.red,
        recurrenceRule: 'FREQ=DAILY;COUNT=20',
        recurrenceExceptionDates: <DateTime>[exceptionDate1],
      ),
    );

    final Appointment recurrenceAppointment = Appointment(
      startTime: DateTime(2021, 04, 12, 10),
      endTime: DateTime(2021, 04, 12, 12),
      subject: 'Daily scrum meeting',
      id: '01',
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1;COUNT=10',
      color: Colors.lightGreen,
      recurrenceExceptionDates: <DateTime>[exceptionDate],
    );
    appointments.add(recurrenceAppointment);

    return _AppointmentDataSource(appointments);
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
