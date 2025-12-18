class ScheduleModel {
  final String gid; // user id
  final String uid; // schedule unique id
  final String title;
  final DateTime start;
  final DateTime end;
  final String? location;
  final bool isAllDay;
  final String? note;
  final int colorValue;
  final String? recurrenceRule;
  final List<DateTime>? exceptionDateList;
  final bool isDone;
  final List<DateTime> doneOccurrences; // For recurring events

  /// Check if this is a recurring event
  bool get isRecurring => recurrenceRule != null && recurrenceRule!.isNotEmpty;

  ScheduleModel({
    required this.gid,
    required this.uid,
    required this.title,
    required this.start,
    required this.end,
    required this.isAllDay,
    this.note,
    this.location,
    this.colorValue = 0xFF42A5F5, // default blue
    this.recurrenceRule,
    this.exceptionDateList,
    this.isDone = false,
    this.doneOccurrences = const [],
  });
}
