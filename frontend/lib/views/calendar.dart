import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/calendar.dart';
import '../models/calendar_event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(calendarControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("CalBot Calendar MVC")),
      body: SfCalendar(
        view: CalendarView.month,
        monthViewSettings: const MonthViewSettings(showAgenda: true),
        dataSource: EventDataSource(events),
        onTap: (details) {
          if (details.date != null) {
            // Controller handles logic
            ref
                .read(calendarControllerProvider.notifier)
                .addEvent(CalendarEvent(title: "New Event", start: details.date!, end: details.date!.add(const Duration(hours: 1)), color: Colors.green));
          }
        },
      ),
    );
  }
}

// Adapter for Syncfusion
class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}
