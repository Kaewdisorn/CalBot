import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/add_schedule_dialog.dart';
import '../widgets/schedule_detail_dialog.dart';
import '../widgets/theme_settings_panel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const allowedViews = [
    CalendarView.day,
    CalendarView.week,
    CalendarView.workWeek,
    CalendarView.timelineDay,
    CalendarView.timelineWeek,
    CalendarView.timelineWorkWeek,
    CalendarView.month,
    CalendarView.schedule,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(scheduleProvider); // auto rebuild
    final theme = ref.watch(themeProvider);
    final seedColor = theme.seedColor ?? Theme.of(context).colorScheme.primary;

    final calendarDataSource = ScheduleDataSource(schedules);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Image.asset('assets/images/halulu.png', width: 36, height: 36), const SizedBox(width: 8), const Text("Halulu")]),
        actions: [IconButton(icon: const Icon(Icons.color_lens), onPressed: () => ThemeSettingsPanel.show(context))],
      ),
      body: SfCalendar(
        view: CalendarView.month,
        showDatePickerButton: true,
        showNavigationArrow: true,
        showTodayButton: true,
        allowedViews: allowedViews,
        headerStyle: CalendarHeaderStyle(
          backgroundColor: seedColor.withAlpha(10),
          textStyle: TextStyle(color: seedColor, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.start,
        ),
        dataSource: calendarDataSource,
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),

        appointmentBuilder: (context, details) {
          final appointment = details.appointments.first as Appointment;
          final schedule = schedules.firstWhere(
            (s) => s.id == (appointment.id?.toString() ?? ''),
            orElse: () => Schedule(
              id: appointment.id?.toString() ?? '',
              title: appointment.subject,
              startDate: appointment.startTime,
              endDate: appointment.endTime,
              description: appointment.notes,
              color: appointment.color,
              isDone: false,
              recurrenceRule: appointment.recurrenceRule,
            ),
          );

          final bgColor = schedule.isDone ? Colors.grey.shade400 : schedule.color ?? Colors.blue;
          final textColor = schedule.isDone ? const Color.fromARGB(137, 172, 142, 142) : Colors.white;

          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
            child: Text(
              '${schedule.isDone ? "✅ " : ""}${schedule.title}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor, decoration: schedule.isDone ? TextDecoration.lineThrough : null),
            ),
          );
        },

        onTap: (details) async {
          if (details.targetElement == CalendarElement.calendarCell) {
            final selectedDate = details.date!;
            await showDialog(
              context: context,
              builder: (_) => AddScheduleDialog(date: selectedDate),
            );
            calendarDataSource.updateAppointments(ref.read(scheduleProvider));
          } else if (details.targetElement == CalendarElement.appointment) {
            final appointment = details.appointments!.first as Appointment;
            final schedule = schedules.firstWhere(
              (s) => s.id == (appointment.id?.toString() ?? ''),
              orElse: () => Schedule(
                id: '',
                title: appointment.subject,
                startDate: appointment.startTime,
                endDate: appointment.endTime,
                description: appointment.notes,
                color: appointment.color,
                isDone: false,
                recurrenceRule: appointment.recurrenceRule,
              ),
            );

            await showDialog(
              context: context,
              builder: (_) => ScheduleDetailDialog(schedule: schedule),
            );
            calendarDataSource.updateAppointments(ref.read(scheduleProvider));
          }
        },
      ),
    );
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> schedules) {
    updateAppointments(schedules);
  }

  void updateAppointments(List<Schedule> schedules) {
    appointments = schedules
        .map(
          (s) => Appointment(
            startTime: s.startDate,
            endTime: s.endDate,
            subject: s.title,
            color: s.color ?? Colors.blue,
            id: s.id,
            notes: s.description,
            recurrenceRule: s.recurrenceRule,
          ),
        )
        .toList();
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => appointments![index].subject;

  @override
  Color getColor(int index) => appointments![index].color!;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String? getRecurrenceRule(int index) => appointments![index].recurrenceRule;
}
