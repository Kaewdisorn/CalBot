import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';
import 'edit_schedule_dialog.dart';

class ScheduleDetailDialog extends ConsumerWidget {
  final Schedule schedule;

  const ScheduleDetailDialog({super.key, required this.schedule});

  // Format date range nicely
  String formatDateRange(DateTime start, DateTime end) {
    final startFmt = DateFormat('EEEE, MMM d HH:mm').format(start);

    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      final endTime = DateFormat('HH:mm').format(end);
      return '$startFmt - $endTime';
    }

    final endFmt = DateFormat('EEEE, MMM d HH:mm').format(end);
    return '$startFmt - $endFmt';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxDialogWidth = constraints.maxWidth < 500 ? constraints.maxWidth : 450.0;

          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxDialogWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Consumer(
                builder: (context, ref, _) {
                  // Safely get current schedule state
                  final schedules = ref.watch(scheduleProvider);
                  final scheduleState = schedules.firstWhere((s) => s.id == schedule.id, orElse: () => schedule);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + action icons
                      Row(
                        children: [
                          Expanded(
                            child: Text(scheduleState.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: "Edit",
                                icon: Icon(Icons.edit, color: colors.primary, size: 20),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (_) => EditScheduleDialog(schedule: scheduleState),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 18,
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                tooltip: "Delete",
                                icon: Icon(Icons.delete, color: colors.error, size: 20),
                                onPressed: () {
                                  ref.read(scheduleProvider.notifier).removeSchedule(scheduleState.id);
                                  Navigator.of(context).pop();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 18,
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                tooltip: "Close",
                                icon: Icon(Icons.close, color: colors.onSurfaceVariant, size: 20),
                                onPressed: () => Navigator.of(context).pop(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 18,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Time info
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(formatDateRange(scheduleState.startDate, scheduleState.endDate), style: const TextStyle(fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),

                      // Optional recurrence
                      if (scheduleState.recurrenceRule != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.repeat, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(scheduleState.recurrenceRule!)),
                          ],
                        ),
                      ],

                      // Optional description
                      if (scheduleState.description != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.note, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(scheduleState.description!)),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Done checkbox at bottom
                      Row(
                        children: [
                          Checkbox(
                            value: scheduleState.isDone,
                            onChanged: (value) {
                              if (value != null) {
                                ref.read(scheduleProvider.notifier).toggleDone(scheduleState.id);
                              }
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                            checkColor: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          const Text("Done", style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
