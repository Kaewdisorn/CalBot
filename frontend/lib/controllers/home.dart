import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeController {
  const HomeController();

  List<CalendarView> get allowedViews => const [CalendarView.day, CalendarView.week, CalendarView.workWeek, CalendarView.month, CalendarView.schedule];
}

final homeControllerProvider = Provider((ref) => const HomeController());
