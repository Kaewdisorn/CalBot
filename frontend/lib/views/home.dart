import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Controllers
import '../controllers/home.dart';

// Models
import '../models/schedule.dart';

// Providers
import '../providers/calendar.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeController = HomeController();
    final calendarController = ref.watch(calendarControllerProvider);
    final dataSource = ref.watch(calendarDataSourceProvider);

    return Scaffold(
      body: SfCalendar(
        controller: calendarController,
        showNavigationArrow: false,
        allowedViews: homeController.allowedViews,
        showDatePickerButton: true,
        //scheduleViewMonthHeaderBuilder: scheduleViewBuilder,
        dataSource: dataSource,
        onTap: (details) {
          if (details.date != null) {
            onCalendarTapped(context, ref, details, homeController);
          }
        },
        onViewChanged: null,
        initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        timeSlotViewSettings: const TimeSlotViewSettings(minimumAppointmentDuration: Duration(minutes: 60)),
      ),
    );
  }

  void onCalendarTapped(BuildContext context, WidgetRef ref, CalendarTapDetails details, HomeController homeController) {
    final DateTime tappedDate = details.date!;

    // Check if an existing schedule was tapped
    if (details.appointments != null && details.targetElement == CalendarElement.appointment) {
      final dynamic appointment = details.appointments![0];
      if (appointment is Schedule) {
        showScheduleDetailsPopup(context, ref, appointment, homeController);
        return;
      }
    }

    // Otherwise, add new schedule
    _showScheduleDialog(context, ref, tappedDate, homeController);
  }

  // Popup for viewing/editing/deleting a schedule
  void showScheduleDetailsPopup(BuildContext context, WidgetRef ref, Schedule selectedSchedule, HomeController homeController) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Schedule Details'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: Icon(Icons.event, color: selectedSchedule.background),
                title: Text(selectedSchedule.eventName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                subtitle: Text('${selectedSchedule.from} - ${selectedSchedule.to}', style: const TextStyle(fontSize: 14)),
              ),
              if (selectedSchedule.isAllDay) const ListTile(leading: Icon(Icons.access_time), title: Text('All-day event')),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pop(context);
                      _showScheduleDialog(context, ref, selectedSchedule.from, homeController, existingSchedule: selectedSchedule);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref.read(scheduleListProvider.notifier).removeSchedule(selectedSchedule);
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, WidgetRef ref, DateTime date, HomeController homeController, {Schedule? existingSchedule}) {
    final titleController = TextEditingController(text: existingSchedule?.eventName ?? '');
    final startController = TextEditingController(text: (existingSchedule?.from ?? date.add(const Duration(hours: 9))).toString());
    final endController = TextEditingController(text: (existingSchedule?.to ?? date.add(const Duration(hours: 10))).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingSchedule != null ? 'Edit Schedule' : 'Add Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: startController,
              decoration: const InputDecoration(labelText: 'Start Time'),
            ),
            TextFormField(
              controller: endController,
              decoration: const InputDecoration(labelText: 'End Time'),
            ),
          ],
        ),
        actions: [
          if (existingSchedule != null)
            TextButton(
              onPressed: () {
                ref.read(scheduleListProvider.notifier).removeSchedule(existingSchedule);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final startTime = DateTime.tryParse(startController.text) ?? date.add(const Duration(hours: 9));
              final endTime = DateTime.tryParse(endController.text) ?? date.add(const Duration(hours: 10));

              final newSchedule = homeController.createSchedule(titleController.text.isEmpty ? '(No Title)' : titleController.text, startTime, endTime);

              final notifier = ref.read(scheduleListProvider.notifier);

              if (existingSchedule != null) {
                // Edit: remove old and add new
                notifier.removeSchedule(existingSchedule);
                notifier.addSchedule(newSchedule);
              } else {
                // Add new schedule
                notifier.addSchedule(newSchedule);
              }

              Navigator.pop(context);
            },
            child: Text(existingSchedule != null ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }
}
