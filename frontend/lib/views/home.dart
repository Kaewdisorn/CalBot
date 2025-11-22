import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Controllers
import '../controllers/home.dart';

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
        //onTap: calendarTapCallback,
        onViewChanged: null,
        initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        timeSlotViewSettings: const TimeSlotViewSettings(minimumAppointmentDuration: Duration(minutes: 60)),
      ),
    );
  }
}
