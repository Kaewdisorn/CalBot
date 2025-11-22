import 'package:flutter/material.dart';

class Event {
  final String name;
  final DateTime from;
  final DateTime to;
  final Color background;
  final bool isAllDay;

  Event(this.name, this.from, this.to, this.background, this.isAllDay);
}
