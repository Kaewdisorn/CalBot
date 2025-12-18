import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/schedule_model.dart';

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<ScheduleModel> models) {
    appointments = models.map((e) => e.toCalendarAppointment()).toList();
  }
}
