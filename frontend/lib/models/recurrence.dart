enum RecurrenceType { none, daily, weekly, monthly, yearly }

class RecurrenceModel {
  final RecurrenceType type;
  final int interval; // every X days/weeks/months/years
  final List<int>? weekdays; // 1=Mon ... 7=Sun (for weekly)
  final DateTime? endDate; // null = no end

  RecurrenceModel({required this.type, this.interval = 1, this.weekdays, this.endDate});

  RecurrenceModel copyWith({RecurrenceType? type, int? interval, List<int>? weekdays, DateTime? endDate}) {
    return RecurrenceModel(type: type ?? this.type, interval: interval ?? this.interval, weekdays: weekdays ?? this.weekdays, endDate: endDate ?? this.endDate);
  }

  static RecurrenceModel none() => RecurrenceModel(type: RecurrenceType.none);
}
