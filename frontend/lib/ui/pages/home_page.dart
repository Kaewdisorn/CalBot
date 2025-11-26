import 'package:flutter/material.dart';

import '../widgets/schedule_calendar.dart';
import '../widgets/schedule_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CalBot Web")),
      body: Row(
        children: [
          Expanded(flex: 1, child: const ScheduleList()),
          VerticalDivider(width: 1),
          Expanded(flex: 2, child: const ScheduleCalendar()),
        ],
      ),
    );
  }
}
