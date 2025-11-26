import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';
import 'edit_schedule_dialog.dart';

class ScheduleDetailDialog extends ConsumerStatefulWidget {
  final Schedule schedule;

  const ScheduleDetailDialog({super.key, required this.schedule});

  @override
  ConsumerState<ScheduleDetailDialog> createState() => _ScheduleDetailDialogState();
}

class _ScheduleDetailDialogState extends ConsumerState<ScheduleDetailDialog> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.schedule.isDone;
  }

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
  Widget build(BuildContext context) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Icons
                  Row(
                    children: [
                      Expanded(
                        child: Text(widget.schedule.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                                builder: (_) => EditScheduleDialog(schedule: widget.schedule),
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
                              ref.read(scheduleProvider.notifier).removeSchedule(widget.schedule.id);
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
                        child: Text(formatDateRange(widget.schedule.startDate, widget.schedule.endDate), style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),

                  // Optional recurrence
                  if (widget.schedule.recurrenceRule != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.repeat, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text(widget.schedule.recurrenceRule!)),
                      ],
                    ),
                  ],

                  // Optional description
                  if (widget.schedule.description != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text(widget.schedule.description!)),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ✅ Custom checkbox at the bottom
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isDone = !_isDone;
                      });
                      ref.read(scheduleProvider.notifier).toggleDone(widget.schedule.id);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _isDone ? const Center(child: Icon(Icons.check, size: 16, color: Colors.black)) : null,
                        ),
                        const SizedBox(width: 8),
                        const Text("Mark as Done", style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
