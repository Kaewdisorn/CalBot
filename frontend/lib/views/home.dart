import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Controllers
import '../controllers/calendar.dart';
import '../controllers/home.dart';
import '../controllers/event.dart';

// Models
import '../models/event.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeController = ref.watch(homeControllerProvider);
    final events = ref.watch(eventProvider);
    final calendarController = ref.watch(calendarControllerProvider);

    // final Widget calendar = Theme(
    //   /// The key set here to maintain the state,
    //   /// when we change the parent of the widget.
    //   //key: _globalKey,
    //   //data: model.themeData.copyWith(colorScheme: model.themeData.colorScheme.copyWith(secondary: model.primaryColor)),
    //   child: getAppointmentEditorCalendar(calendarController, _events, _onCalendarTapped, _onViewChanged, scheduleViewBuilder),
    // );

    // final Widget calendar = getAppointmentEditorCalendar(calendarController, EventDataSource(events), _onCalendarTapped, _onViewChanged, scheduleViewBuilder);

    // /// Returns the Calendar based on the properties passed.
    // SfCalendar getAppointmentEditorCalendar([
    //   CalendarController? calendarController,
    //   CalendarDataSource? calendarDataSource,
    //   dynamic calendarTapCallback,
    //   ViewChangedCallback? viewChangedCallback,
    //   dynamic scheduleViewBuilder,
    // ]) {
    //   return SfCalendar(
    //     controller: calendarController,
    //     //showNavigationArrow: model.isWebFullView,
    //     allowedViews: homeController.allowedViews,
    //     showDatePickerButton: true,
    //     scheduleViewMonthHeaderBuilder: scheduleViewBuilder,
    //     dataSource: calendarDataSource,
    //     onTap: calendarTapCallback,
    //     onViewChanged: viewChangedCallback,
    //     initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    //     monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    //     timeSlotViewSettings: const TimeSlotViewSettings(minimumAppointmentDuration: Duration(minutes: 60)),
    //   );
    // }

    return Scaffold(
      body: SfCalendar(
        controller: calendarController,
        //showNavigationArrow: model.isWebFullView,
        allowedViews: homeController.allowedViews,
        showDatePickerButton: true,
        //scheduleViewMonthHeaderBuilder: scheduleViewBuilder,
        dataSource: EventDataSource(events),
        //onTap: calendarTapCallback,
        //onViewChanged: viewChangedCallback,
        initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        timeSlotViewSettings: const TimeSlotViewSettings(minimumAppointmentDuration: Duration(minutes: 60)),
      ),
    );

    // return Scaffold(
    //   body: SfCalendar(
    //     allowedViews: homeController.allowedViews,
    //     dataSource: EventDataSource(events),
    //     monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       final now = DateTime.now();
    //       ref.read(eventProvider.notifier).addEvent(Event('New Meeting', now, now.add(const Duration(hours: 1)), Colors.blue, false));
    //     },
    //     child: const Icon(Icons.add),
    //   ),
    // );
  }
}

/// Calendar data source mapping
class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => _getEvent(index).from;

  @override
  DateTime getEndTime(int index) => _getEvent(index).to;

  @override
  String getSubject(int index) => _getEvent(index).name;

  @override
  Color getColor(int index) => _getEvent(index).background;

  @override
  bool isAllDay(int index) => _getEvent(index).isAllDay;

  Event _getEvent(int index) => appointments![index] as Event;
}
