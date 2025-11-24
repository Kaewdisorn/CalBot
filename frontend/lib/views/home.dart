import 'dart:convert';
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
          final appointment = details.appointments.first as Appointment;

          // Decode notes JSON to get description and isDone
          final notes = appointment.notes != null ? jsonDecode(appointment.notes!) : {};
          final isDone = notes['isDone'] ?? false;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isDone
                  ? appointment.color.withAlpha((0.35 * 255).round()) // 35% opacity
                  : appointment.color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                if (isDone) const Icon(Icons.check, size: 14, color: Colors.white),
                if (isDone) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    appointment.subject,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none),
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
            final selected = details.appointments!.first as Appointment;

            showDialog(
              context: context,
              builder: (_) => ScheduleDialog(date: date, homeController: homeController, existingAppointment: selected),
            );
            return;
          }

          // Create new appointment
          showDialog(
            context: context,
            builder: (_) => ScheduleDialog(date: date, homeController: homeController),
          );
        },

        initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),

        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),

        timeSlotViewSettings: const TimeSlotViewSettings(minimumAppointmentDuration: Duration(minutes: 60)),
      ),
    );
  }
}
