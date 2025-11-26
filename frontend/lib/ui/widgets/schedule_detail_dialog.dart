import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/schedule.dart';
import 'edit_schedule_dialog.dart';

class ScheduleDetailDialog extends ConsumerWidget {
  final Schedule schedule;

  const ScheduleDetailDialog({super.key, required this.schedule});

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
          final maxDialogWidth = constraints.maxWidth < 500 ? constraints.maxWidth : 450.0; // Responsive width
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxDialogWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + icons
                  Row(
                    children: [
                      Expanded(
                        child: Text(schedule.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                                builder: (_) => EditScheduleDialog(schedule: schedule),
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
                              // TODO: remove from provider
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
                        child: Text(formatDateRange(schedule.startDate, schedule.endDate), style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),

                  // Optional recurrence
                  if (schedule.recurrenceRule != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.repeat, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text(schedule.recurrenceRule!)),
                      ],
                    ),
                  ],

                  // Optional description
                  if (schedule.description != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text(schedule.description!)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
