import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/schedule_provider.dart';

class ScheduleList extends ConsumerWidget {
  const ScheduleList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(scheduleProvider);

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (_, i) {
        final s = schedules[i];
        return ListTile(title: Text(s.title), subtitle: Text(s.date.toString()));
      },
    );
  }
}
