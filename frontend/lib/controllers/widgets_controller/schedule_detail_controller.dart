import 'dart:convert';

import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleDetailController extends GetxController {
  final RxBool isdone = false.obs;

  void checkIsDone(Appointment appointment) {
    if (appointment.notes != null && appointment.notes!.isNotEmpty) {
      final noteData = jsonDecode(appointment.notes!);
      isdone.value = noteData['isDone'];
    } else {
      isdone.value = false;
    }
  }
}
