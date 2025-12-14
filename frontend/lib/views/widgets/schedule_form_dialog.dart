import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/widgets_controller/schedule_form_controller.dart';
import '../../models/schedule_model.dart';

/// A professional, reusable dialog for adding/editing schedules.
/// Pass [existingSchedule] to edit mode, or leave null for add mode.
/// For recurring events, pass [tappedOccurrenceDate] to track which occurrence was tapped.
class ScheduleFormDialog extends StatelessWidget {
  final ScheduleModel? existingSchedule;
  final DateTime? initialDate;
  final DateTime? tappedOccurrenceDate; // For recurring events - the specific occurrence that was tapped
  final Function(ScheduleModel) onSave;
  final VoidCallback? onDelete; // Delete entire series
  final Function(DateTime)? onDeleteSingle; // Delete single occurrence (for recurring events)

  const ScheduleFormDialog({
    super.key,
    this.existingSchedule,
    this.initialDate,
    this.tappedOccurrenceDate,
    required this.onSave,
    this.onDelete,
    this.onDeleteSingle,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScheduleFormController());
    controller.initialize(schedule: existingSchedule, initialDate: initialDate, tappedOccurrenceDate: tappedOccurrenceDate);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

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

                        // All Day & Mark as Done Row
                        _buildAllDayAndDoneRow(controller),
                        const SizedBox(height: 12),

                        // Date & Time Pickers
                        _buildDateTimePickers(context, controller),
                        const SizedBox(height: 16),

                        // Recurrence Picker
                        _buildRecurrencePicker(context, controller),
                        const SizedBox(height: 16),

                        // Location Field
                        _buildLocationField(controller),
                        const SizedBox(height: 16),

                        // Note Field
                        _buildNoteField(controller),
                        const SizedBox(height: 16),

                        // Color Picker with custom color input
                        _buildColorPicker(controller),
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
    final selectedColor = controller.selectedColor.value;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        color: selectedColor.withAlpha(25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(2)),
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
    final themeColor = Theme.of(Get.context!).colorScheme.primary;
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
          borderSide: BorderSide(color: themeColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildAllDayAndDoneRow(ScheduleFormController controller) {
    final themeColor = Theme.of(Get.context!).colorScheme.primary;
    final isDone = controller.isDone.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // All Day section
          Expanded(
            child: Row(
              children: [
                Icon(Icons.sunny, color: themeColor, size: 20),
                const SizedBox(width: 6),
                const Text('All Day', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const Spacer(),
                Switch(
                  value: controller.isAllDay.value,
                  onChanged: controller.toggleAllDay,
                  activeThumbColor: themeColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
          Container(width: 1, height: 28, color: Colors.grey.shade300),
          // Mark as Done section
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(isDone ? Icons.check_circle : Icons.check_circle_outline, color: isDone ? Colors.green : Colors.grey.shade600, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Mark as Done',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDone ? Colors.green.shade700 : Colors.black87),
                ),
                const Spacer(),
                Checkbox(
                  value: isDone,
                  onChanged: (val) => controller.toggleIsDone(val ?? false),
                  activeColor: Colors.green,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickers(BuildContext context, ScheduleFormController controller) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final themeColor = Theme.of(context).colorScheme.primary;

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
          color: themeColor,
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
          color: themeColor,
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
    final themeColor = Theme.of(Get.context!).colorScheme.primary;
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
          borderSide: BorderSide(color: themeColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildNoteField(ScheduleFormController controller) {
    final themeColor = Theme.of(Get.context!).colorScheme.primary;
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
          borderSide: BorderSide(color: themeColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildColorPicker(ScheduleFormController controller) {
    final selectedColor = controller.selectedColor.value;
    final themeColor = Theme.of(Get.context!).colorScheme.primary;
    // Check if current color is a preset color
    final isPresetColor = ScheduleFormController.colorPalette.any((c) => c.toARGB32() == selectedColor.toARGB32());

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
        // Single row: Preview + Preset colors + Custom input
        Row(
          children: [
            // Current color preview
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [BoxShadow(color: selectedColor.withAlpha(100), blurRadius: 4, offset: const Offset(0, 2))],
              ),
            ),
            const SizedBox(width: 10),
            // Preset color circles
            ...ScheduleFormController.colorPalette.map((color) {
              final isSelected = selectedColor.toARGB32() == color.toARGB32();
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => controller.setColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                      boxShadow: [
                        BoxShadow(color: isSelected ? color.withAlpha(150) : Colors.black12, blurRadius: isSelected ? 4 : 2, offset: const Offset(0, 1)),
                      ],
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                  ),
                ),
              );
            }),
            // Custom color indicator (if custom color is selected)
            if (!isPresetColor)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: selectedColor.withAlpha(150), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            const SizedBox(width: 4),
            // Custom hex input
            Expanded(
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: controller.customColorController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Hex',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    prefixText: '#',
                    prefixStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: themeColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onSubmitted: (_) => controller.applyCustomColor(),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Apply button
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: controller.applyCustomColor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecurrencePicker(BuildContext context, ScheduleFormController controller) {
    final themeColor = Theme.of(context).colorScheme.primary;
    final isRecurring = controller.recurrenceFrequency.value != RecurrenceFrequency.never;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Repeat dropdown
        Row(
          children: [
            Icon(Icons.repeat, color: themeColor, size: 22),
            const SizedBox(width: 12),
            Text('Repeat', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RecurrenceFrequency>(
                    value: controller.recurrenceFrequency.value,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: themeColor),
                    style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: isRecurring ? FontWeight.w500 : FontWeight.normal),
                    items: const [
                      DropdownMenuItem(value: RecurrenceFrequency.never, child: Text('Never')),
                      DropdownMenuItem(value: RecurrenceFrequency.daily, child: Text('Daily')),
                      DropdownMenuItem(value: RecurrenceFrequency.weekly, child: Text('Weekly')),
                      DropdownMenuItem(value: RecurrenceFrequency.monthly, child: Text('Monthly')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setRecurrenceFrequency(value);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        // Show additional options based on frequency
        if (isRecurring) ...[const SizedBox(height: 12), _buildRecurrenceOptions(context, controller, themeColor)],
      ],
    );
  }

  Widget _buildRecurrenceOptions(BuildContext context, ScheduleFormController controller, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Interval + End condition (combined for compact layout)
          Row(
            children: [
              // Interval picker
              Expanded(child: _buildIntervalRow(controller, color)),
              const SizedBox(width: 12),
              // End dropdown (inline)
              _buildCompactEndDropdown(controller, color),
            ],
          ),

          // Row 2: End date/count picker if needed
          if (controller.recurrenceEndType.value != RecurrenceEndType.never) ...[const SizedBox(height: 8), _buildEndValuePicker(context, controller, color)],

          // Weekly: day selector
          if (controller.recurrenceFrequency.value == RecurrenceFrequency.weekly) ...[const SizedBox(height: 10), _buildWeekDaySelector(controller, color)],

          // Monthly: day or week position selector
          if (controller.recurrenceFrequency.value == RecurrenceFrequency.monthly) ...[const SizedBox(height: 10), _buildMonthlySelector(controller, color)],
        ],
      ),
    );
  }

  Widget _buildCompactEndDropdown(ScheduleFormController controller, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RecurrenceEndType>(
          value: controller.recurrenceEndType.value,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: color),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: const [
            DropdownMenuItem(value: RecurrenceEndType.never, child: Text('Forever')),
            DropdownMenuItem(value: RecurrenceEndType.until, child: Text('Until')),
            DropdownMenuItem(value: RecurrenceEndType.count, child: Text('Count')),
          ],
          onChanged: (value) {
            if (value != null) controller.setRecurrenceEndType(value);
          },
        ),
      ),
    );
  }

  Widget _buildEndValuePicker(BuildContext context, ScheduleFormController controller, Color color) {
    if (controller.recurrenceEndType.value == RecurrenceEndType.until) {
      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.recurrenceEndDate.value ?? controller.startDate.value.add(const Duration(days: 30)),
            firstDate: controller.startDate.value,
            lastDate: DateTime(2100),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: color)),
              child: child!,
            ),
          );
          if (picked != null) controller.setRecurrenceEndDate(picked);
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                controller.recurrenceEndDate.value != null ? DateFormat('MMM d, yyyy').format(controller.recurrenceEndDate.value!) : 'Select end date',
                style: TextStyle(fontSize: 13, color: controller.recurrenceEndDate.value != null ? Colors.black87 : Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else if (controller.recurrenceEndType.value == RecurrenceEndType.count) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('After', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(width: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: controller.recurrenceCount.value > 1 ? () => controller.setRecurrenceCount(controller.recurrenceCount.value - 1) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Icon(Icons.remove, size: 16, color: controller.recurrenceCount.value > 1 ? color : Colors.grey.shade400),
                  ),
                ),
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Text('${controller.recurrenceCount.value}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                InkWell(
                  onTap: () => controller.setRecurrenceCount(controller.recurrenceCount.value + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Icon(Icons.add, size: 16, color: color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            controller.recurrenceFrequency.value == RecurrenceFrequency.weekly ? 'weeks' : 'times',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text('times', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildIntervalRow(ScheduleFormController controller, Color color) {
    String unitLabel;
    switch (controller.recurrenceFrequency.value) {
      case RecurrenceFrequency.daily:
        unitLabel = controller.recurrenceInterval.value == 1 ? 'day' : 'days';
        break;
      case RecurrenceFrequency.weekly:
        unitLabel = controller.recurrenceInterval.value == 1 ? 'week' : 'weeks';
        break;
      case RecurrenceFrequency.monthly:
        unitLabel = controller.recurrenceInterval.value == 1 ? 'month' : 'months';
        break;
      default:
        unitLabel = 'days';
    }

    return Row(
      children: [
        Text('Every', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        const SizedBox(width: 8),
        // Interval stepper
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: controller.recurrenceInterval.value > 1 ? () => controller.setRecurrenceInterval(controller.recurrenceInterval.value - 1) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Icon(Icons.remove, size: 18, color: controller.recurrenceInterval.value > 1 ? color : Colors.grey.shade400),
                ),
              ),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text('${controller.recurrenceInterval.value}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              InkWell(
                onTap: () => controller.setRecurrenceInterval(controller.recurrenceInterval.value + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Icon(Icons.add, size: 18, color: color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(unitLabel, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildWeekDaySelector(ScheduleFormController controller, Color color) {
    final days = [
      (WeekDay.monday, 'M', 'Mon'),
      (WeekDay.tuesday, 'T', 'Tue'),
      (WeekDay.wednesday, 'W', 'Wed'),
      (WeekDay.thursday, 'T', 'Thu'),
      (WeekDay.friday, 'F', 'Fri'),
      (WeekDay.saturday, 'S', 'Sat'),
      (WeekDay.sunday, 'S', 'Sun'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('On', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) {
            final isSelected = controller.selectedWeekDays.contains(day.$1);
            return Tooltip(
              message: day.$3,
              child: GestureDetector(
                onTap: () => controller.toggleWeekDay(day.$1),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? color : Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      day.$2,
                      style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlySelector(ScheduleFormController controller, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode toggle: By Day or By Week
        Row(
          children: [
            _buildModeChip(
              label: 'Day',
              isSelected: controller.monthlyRepeatMode.value == MonthlyRepeatMode.byDay,
              color: color,
              onTap: () => controller.setMonthlyRepeatMode(MonthlyRepeatMode.byDay),
            ),
            const SizedBox(width: 8),
            _buildModeChip(
              label: 'Week',
              isSelected: controller.monthlyRepeatMode.value == MonthlyRepeatMode.byWeekPosition,
              color: color,
              onTap: () => controller.setMonthlyRepeatMode(MonthlyRepeatMode.byWeekPosition),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Options based on mode
        if (controller.monthlyRepeatMode.value == MonthlyRepeatMode.byDay) _buildByDayOption(controller, color) else _buildByWeekOption(controller, color),
      ],
    );
  }

  Widget _buildModeChip({required String label, required bool isSelected, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildByDayOption(ScheduleFormController controller, Color color) {
    return Row(
      children: [
        Text('On day', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        const SizedBox(width: 6),
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: controller.monthlyDay.value.clamp(1, 31),
              isExpanded: true,
              isDense: true,
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: color),
              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
              items: List.generate(31, (i) => i + 1).map((day) => DropdownMenuItem(value: day, child: Text('$day'))).toList(),
              onChanged: (value) {
                if (value != null) controller.setMonthlyDay(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildByWeekOption(ScheduleFormController controller, Color color) {
    return Row(
      children: [
        // Week position dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<WeekPosition>(
              value: controller.monthlyWeekPosition.value,
              isDense: true,
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: color),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: const [
                DropdownMenuItem(value: WeekPosition.first, child: Text('First')),
                DropdownMenuItem(value: WeekPosition.second, child: Text('Second')),
                DropdownMenuItem(value: WeekPosition.third, child: Text('Third')),
                DropdownMenuItem(value: WeekPosition.fourth, child: Text('Fourth')),
                DropdownMenuItem(value: WeekPosition.last, child: Text('Last')),
              ],
              onChanged: (value) {
                if (value != null) controller.setMonthlyWeekPosition(value);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Weekday dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<WeekDay>(
              value: controller.monthlyWeekDay.value,
              isDense: true,
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: color),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: WeekDay.values.map((day) {
                return DropdownMenuItem(value: day, child: Text(controller.getWeekDayName(day)));
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.setMonthlyWeekDay(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ScheduleFormController controller) {
    final themeColor = Theme.of(Get.context!).colorScheme.primary;

    // If in edit mode with delete option, show both buttons in a row
    if (controller.isEditMode && onDelete != null) {
      return Row(
        children: [
          // Delete Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleDelete(controller),
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
                backgroundColor: themeColor,
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
          backgroundColor: themeColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, ScheduleFormController controller, {required bool isStart}) async {
    final initial = isStart ? controller.startDate.value : controller.endDate.value;
    final themeColor = Theme.of(context).colorScheme.primary;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: themeColor)),
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
    final themeColor = Theme.of(context).colorScheme.primary;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: themeColor)),
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

  void _handleDelete(ScheduleFormController controller) {
    // Check if this is a recurring event
    if (existingSchedule != null && existingSchedule!.isRecurring && tappedOccurrenceDate != null) {
      // Show confirmation dialog for recurring events
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Delete Event'),
            ],
          ),
          content: const Text('This is a recurring event. What would you like to delete?'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            OutlinedButton(
              onPressed: () {
                Get.back(); // Close confirmation dialog
                Get.delete<ScheduleFormController>();
                Get.back(); // Close form dialog
                onDeleteSingle?.call(tappedOccurrenceDate!);
              },
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange)),
              child: const Text('This Event Only', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close confirmation dialog
                Get.delete<ScheduleFormController>();
                Get.back(); // Close form dialog
                onDelete?.call();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('All Events', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      // Non-recurring event - delete directly
      Get.delete<ScheduleFormController>();
      Get.back();
      onDelete?.call();
    }
  }
}
