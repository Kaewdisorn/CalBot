import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class ScheduleDetailPopup extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ScheduleDetailPopup({super.key, required this.appointment, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
          return Center(
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 40,
                          decoration: BoxDecoration(color: appointment.color, borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appointment.subject,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(height: 30),

                    // --- Date & Time ---
                    _buildInfoRow(
                      Icons.access_time,
                      DateFormat('MMM d, yyyy').format(appointment.startTime),
                      "${DateFormat('h:mm a').format(appointment.startTime)} - ${DateFormat('h:mm a').format(appointment.endTime)}",
                    ),
                    const SizedBox(height: 15),

                    // --- Location (Conditional) ---
                    if (appointment.location != null && appointment.location!.isNotEmpty) _buildInfoRow(Icons.location_on, "Location", appointment.location!),

                    // --- Notes (Conditional) ---
                    if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: Text(appointment.notes!, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                      ),
                    ],

                    const SizedBox(height: 25),

                    // --- Action Buttons ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              if (onEdit != null) onEdit!();
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text("Edit"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              if (onDelete != null) onDelete!();
                            },
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                            label: const Text("Delete", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
