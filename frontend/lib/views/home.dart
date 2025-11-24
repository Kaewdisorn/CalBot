import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Controllers
import '../controllers/home.dart';

// Providers
import '../providers/calendar.dart';

// Widgets
import 'schedule.dart';

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
        dataSource: dataSource,
        appointmentBuilder: (context, details) {
          final schedule = details.appointments.first;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: schedule.isDone ? schedule.background.withOpacity(0.35) : schedule.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                if (schedule.isDone) const Icon(Icons.check, size: 14, color: Colors.white),

                if (schedule.isDone) const SizedBox(width: 4),

                Expanded(
                  child: Text(
                    schedule.eventName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: schedule.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        },

        onTap: (details) {
          if (details.targetElement == CalendarElement.header) return;

          final date = details.date;
          if (date == null) return;

          // Edit existing appointment
          if (details.appointments != null && details.appointments!.isNotEmpty && details.targetElement == CalendarElement.appointment) {
            final selected = details.appointments!.first;

            showDialog(
              context: context,
              builder: (_) => ScheduleDialog(date: date, homeController: homeController, existingSchedule: selected),
            );
            return;
          }

          // Create new
          showDialog(
            context: context,
            builder: (_) => ScheduleDialog(date: date, homeController: homeController),
          );
        },

        onViewChanged: null,
        initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),

        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),

        timeSlotViewSettings: const TimeSlotViewSettings(minimumAppointmentDuration: Duration(minutes: 60)),
      ),
    );
  }
}
