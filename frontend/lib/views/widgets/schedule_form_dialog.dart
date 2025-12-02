import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/widgets_controller/schedule_form_controller.dart';
import '../../models/schedule_model.dart';

/// A professional, reusable dialog for adding/editing schedules.
/// Pass [existingSchedule] to edit mode, or leave null for add mode.
class ScheduleFormDialog extends StatelessWidget {
  final ScheduleModel? existingSchedule;
  final DateTime? initialDate;
  final Function(ScheduleModel) onSave;
  final VoidCallback? onDelete;

  const ScheduleFormDialog({super.key, this.existingSchedule, this.initialDate, required this.onSave, this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Create and initialize controller
    final controller = Get.put(ScheduleFormController());
    controller.initialize(schedule: existingSchedule, initialDate: initialDate);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    // Dialog width based on screen size
    double dialogWidth;
    if (isMobile) {
      dialogWidth = screenWidth * 0.95;
    } else if (isTablet) {
      dialogWidth = 500;
    } else {
      dialogWidth = 520;
    }

    // Max height based on screen size
    final maxHeight = isMobile ? screenHeight * 0.9 : screenHeight * 0.85;

    // Padding based on screen size
    final horizontalPadding = isMobile ? 8.0 : 16.0;
    final contentPadding = isMobile ? 16.0 : 24.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: Center(
        child: Obx(
          () => Container(
            width: dialogWidth,
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(controller),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(contentPadding, 16, contentPadding, contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        _buildTitleField(controller),
                        const SizedBox(height: 16),

                        // All Day Toggle
                        _buildAllDayToggle(controller),
                        const SizedBox(height: 12),

                        // Date & Time Pickers
                        _buildDateTimePickers(context, controller),
                        const SizedBox(height: 16),

                        // Location Field
                        _buildLocationField(controller),
                        const SizedBox(height: 16),

                        // Note Field
                        _buildNoteField(controller),
                        const SizedBox(height: 16),

                        // Color Picker & Mark as Done in Row
                        _buildColorAndDoneRow(controller, isMobile),
                        const SizedBox(height: 20),

                        // Action Buttons
                        _buildActionButtons(controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ScheduleFormController controller) {
    final color = controller.selectedColor.value;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.isEditMode ? 'Edit Schedule' : 'New Schedule',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () {
              Get.delete<ScheduleFormController>();
              Get.back();
            },
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(ScheduleFormController controller) {
    final color = controller.selectedColor.value;
    return TextField(
      controller: controller.titleController,
      autofocus: !controller.isEditMode,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Enter schedule title',
        prefixIcon: const Icon(Icons.event_note_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildAllDayToggle(ScheduleFormController controller) {
    final color = controller.selectedColor.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.sunny, color: color, size: 22),
              const SizedBox(width: 12),
              const Text('All Day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          Switch(value: controller.isAllDay.value, onChanged: controller.toggleAllDay, activeThumbColor: color),
        ],
      ),
    );
  }

  Widget _buildDateTimePickers(BuildContext context, ScheduleFormController controller) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final color = controller.selectedColor.value;

    return Column(
      children: [
        // Start Date/Time
        _buildDateTimeRow(
          context: context,
          controller: controller,
          label: 'Start',
          icon: Icons.schedule_outlined,
          date: controller.startDate.value,
          time: controller.startTime.value,
          dateStr: dateFormat.format(controller.startDate.value),
          timeStr: timeFormat.format(DateTime(2000, 1, 1, controller.startTime.value.hour, controller.startTime.value.minute)),
          onDateTap: () => _pickDate(context, controller, isStart: true),
          onTimeTap: controller.isAllDay.value ? null : () => _pickTime(context, controller, isStart: true),
          color: color,
        ),
        const SizedBox(height: 12),
        // End Date/Time
        _buildDateTimeRow(
          context: context,
          controller: controller,
          label: 'End',
          icon: Icons.schedule,
          date: controller.endDate.value,
          time: controller.endTime.value,
          dateStr: dateFormat.format(controller.endDate.value),
          timeStr: timeFormat.format(DateTime(2000, 1, 1, controller.endTime.value.hour, controller.endTime.value.minute)),
          onDateTap: () => _pickDate(context, controller, isStart: false),
          onTimeTap: controller.isAllDay.value ? null : () => _pickTime(context, controller, isStart: false),
          color: color,
        ),
      ],
    );
  }

  Widget _buildDateTimeRow({
    required BuildContext context,
    required ScheduleFormController controller,
    required String label,
    required IconData icon,
    required DateTime date,
    required TimeOfDay time,
    required String dateStr,
    required String timeStr,
    required VoidCallback onDateTap,
    VoidCallback? onTimeTap,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        SizedBox(
          width: 45,
          child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ),
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: onDateTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateStr, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        if (!controller.isAllDay.value) ...[
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: onTimeTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(timeStr, style: const TextStyle(fontSize: 14)),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationField(ScheduleFormController controller) {
    final color = controller.selectedColor.value;
    return TextField(
      controller: controller.locationController,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Location',
        hintText: 'Add location (optional)',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildNoteField(ScheduleFormController controller) {
    final color = controller.selectedColor.value;
    return TextField(
      controller: controller.noteController,
      style: const TextStyle(fontSize: 16),
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes',
        hintText: 'Add notes (optional)',
        prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 48), child: Icon(Icons.notes_outlined)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildColorAndDoneRow(ScheduleFormController controller, bool isMobile) {
    // if (isMobile) {
    // Stack vertically on mobile
    return Column(children: [_buildColorPicker(controller), const SizedBox(height: 12), _buildMarkAsDoneToggle(controller)]);
    // }

    // Side by side on larger screens
    // return Row(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Expanded(child: _buildColorPicker(controller)),
    //     const SizedBox(width: 16),
    //     Expanded(child: _buildMarkAsDoneToggle(controller)),
    //   ],
    // );
  }

  Widget _buildColorPicker(ScheduleFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette_outlined, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'Color',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ScheduleFormController.colorPalette.map((color) {
            final isSelected = controller.selectedColor.value.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () => controller.setColor(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  boxShadow: [BoxShadow(color: isSelected ? color.withAlpha(150) : Colors.black12, blurRadius: isSelected ? 6 : 3, offset: const Offset(0, 2))],
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMarkAsDoneToggle(ScheduleFormController controller) {
    final isDone = controller.isDone.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDone ? Colors.green.shade300 : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isDone ? Icons.check_circle : Icons.check_circle_outline, color: isDone ? Colors.green : Colors.grey.shade600, size: 22),
              const SizedBox(width: 12),
              Text(
                'Mark as Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDone ? Colors.green.shade700 : Colors.black87),
              ),
            ],
          ),
          Checkbox(
            value: isDone,
            onChanged: (val) => controller.toggleIsDone(val ?? false),
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ScheduleFormController controller) {
    final color = controller.selectedColor.value;

    // If in edit mode with delete option, show both buttons in a row
    if (controller.isEditMode && onDelete != null) {
      return Row(
        children: [
          // Delete Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Get.delete<ScheduleFormController>();
                Get.back();
                onDelete!();
              },
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
              label: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Save Button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _handleSave(controller),
              icon: const Icon(Icons.save, color: Colors.white, size: 18),
              label: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
            ),
          ),
        ],
      );
    }

    // Add mode - only show add button
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleSave(controller),
        icon: const Icon(Icons.add, color: Colors.white, size: 18),
        label: const Text(
          'Add Schedule',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, ScheduleFormController controller, {required bool isStart}) async {
    final initial = isStart ? controller.startDate.value : controller.endDate.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: controller.selectedColor.value)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isStart) {
        controller.setStartDate(picked);
      } else {
        controller.setEndDate(picked);
      }
    }
  }

  Future<void> _pickTime(BuildContext context, ScheduleFormController controller, {required bool isStart}) async {
    final initial = isStart ? controller.startTime.value : controller.endTime.value;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: controller.selectedColor.value)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isStart) {
        controller.setStartTime(picked);
      } else {
        controller.setEndTime(picked);
      }
    }
  }

  void _handleSave(ScheduleFormController controller) {
    final schedule = controller.buildSchedule();
    if (schedule != null) {
      Get.delete<ScheduleFormController>();
      Get.back();
      onSave(schedule);
    }
  }
}
