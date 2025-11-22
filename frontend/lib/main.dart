import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/calendar.dart';

void main() {
  runApp(const ProviderScope(child: CalBotApp()));
}

class CalBotApp extends StatelessWidget {
  const CalBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'CalBot MVC Calendar', home: const CalendarPage());
  }
}
