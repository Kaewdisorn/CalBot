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
  final VoidCallback? onDelete;

  const ScheduleFormDialog({super.key, this.existingSchedule, this.initialDate, this.tappedOccurrenceDate, required this.onSave, this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Create and initialize controller
    final controller = Get.put(ScheduleFormController());
    controller.initialize(schedule: existingSchedule, initialDate: initialDate, tappedOccurrenceDate: tappedOccurrenceDate);

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

                        // Recurrence Picker
                        _buildRecurrencePicker(context, controller),
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

  Widget _buildRecurrencePicker(BuildContext context, ScheduleFormController controller) {
    final color = controller.selectedColor.value;
    final isRecurring = controller.recurrenceFrequency.value != RecurrenceFrequency.none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recurrence toggle/selector
        InkWell(
          onTap: () => _showRecurrenceDialog(context, controller),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isRecurring ? color.withAlpha(15) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isRecurring ? color.withAlpha(100) : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.repeat, color: isRecurring ? color : Colors.grey.shade600, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repeat',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.getRecurrenceDescription(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isRecurring ? color : Colors.black87,
                          fontWeight: isRecurring ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRecurrenceDialog(BuildContext context, ScheduleFormController controller) {
    final color = controller.selectedColor.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Obx(
        () => Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.repeat, color: color),
                    const SizedBox(width: 12),
                    const Text('Repeat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Done',
                        style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Frequency options
                      _buildFrequencyOptions(controller, color),
                      const SizedBox(height: 20),

                      // Advanced options (only show if recurring)
                      if (controller.recurrenceFrequency.value != RecurrenceFrequency.none) ...[
                        // Custom interval
                        if (controller.recurrenceFrequency.value == RecurrenceFrequency.custom) ...[
                          _buildIntervalPicker(controller, color),
                          const SizedBox(height: 16),
                        ],

                        // Weekly day selector
                        if (controller.recurrenceFrequency.value == RecurrenceFrequency.weekly ||
                            (controller.recurrenceFrequency.value == RecurrenceFrequency.custom && controller.selectedWeekDays.isNotEmpty)) ...[
                          _buildWeekDaySelector(controller, color),
                          const SizedBox(height: 16),
                        ],

                        // Monthly options
                        if (controller.recurrenceFrequency.value == RecurrenceFrequency.monthly) ...[
                          _buildMonthlyOptions(controller, color),
                          const SizedBox(height: 16),
                        ],

                        // End condition
                        _buildEndCondition(context, controller, color),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyOptions(ScheduleFormController controller, Color color) {
    final options = [
      (RecurrenceFrequency.none, 'Does not repeat', Icons.close),
      (RecurrenceFrequency.daily, 'Every day', Icons.today),
      (RecurrenceFrequency.weekly, 'Every week', Icons.view_week),
      (RecurrenceFrequency.monthly, 'Every month', Icons.calendar_view_month),
      (RecurrenceFrequency.yearly, 'Every year', Icons.event),
      (RecurrenceFrequency.custom, 'Custom...', Icons.tune),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = controller.recurrenceFrequency.value == option.$1;
        return InkWell(
          onTap: () => controller.setRecurrenceFrequency(option.$1),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(20) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(option.$3, size: 18, color: isSelected ? color : Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  option.$2,
                  style: TextStyle(fontSize: 14, color: isSelected ? color : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntervalPicker(ScheduleFormController controller, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat every',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Interval number
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: controller.recurrenceInterval.value > 1 ? () => controller.setRecurrenceInterval(controller.recurrenceInterval.value - 1) : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 36),
                  ),
                  Expanded(
                    child: Text(
                      '${controller.recurrenceInterval.value}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => controller.setRecurrenceInterval(controller.recurrenceInterval.value + 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Unit dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withAlpha(50)),
              ),
              child: Text(
                controller.selectedWeekDays.isNotEmpty
                    ? (controller.recurrenceInterval.value == 1 ? 'week' : 'weeks')
                    : (controller.recurrenceInterval.value == 1 ? 'day' : 'days'),
                style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekDaySelector(ScheduleFormController controller, Color color) {
    final days = [
      (WeekDay.monday, 'M'),
      (WeekDay.tuesday, 'T'),
      (WeekDay.wednesday, 'W'),
      (WeekDay.thursday, 'T'),
      (WeekDay.friday, 'F'),
      (WeekDay.saturday, 'S'),
      (WeekDay.sunday, 'S'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat on',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((day) {
            final isSelected = controller.selectedWeekDays.contains(day.$1);
            return GestureDetector(
              onTap: () => controller.toggleWeekDay(day.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    day.$2,
                    style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyOptions(ScheduleFormController controller, Color color) {
    final dayOfMonth = controller.startDate.value.day;
    final weekOfMonth = ((dayOfMonth - 1) ~/ 7) + 1;
    final weekdayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][controller.startDate.value.weekday - 1];
    final ordinal = _getOrdinalSuffix(weekOfMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly on',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => controller.setMonthlyOption(0),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: controller.monthlyOption.value == 0 ? color.withAlpha(20) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: controller.monthlyOption.value == 0 ? color : Colors.transparent, width: 1.5),
                  ),
                  child: Text(
                    'Day $dayOfMonth',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.monthlyOption.value == 0 ? color : Colors.black87,
                      fontWeight: controller.monthlyOption.value == 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => controller.setMonthlyOption(1),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: controller.monthlyOption.value == 1 ? color.withAlpha(20) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: controller.monthlyOption.value == 1 ? color : Colors.transparent, width: 1.5),
                  ),
                  child: Text(
                    '$ordinal $weekdayName',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.monthlyOption.value == 1 ? color : Colors.black87,
                      fontWeight: controller.monthlyOption.value == 1 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEndCondition(BuildContext context, ScheduleFormController controller, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ends',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        // End by count
        InkWell(
          onTap: () => controller.setUseEndDate(false),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: !controller.useEndDate.value ? color.withAlpha(15) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: !controller.useEndDate.value ? color.withAlpha(100) : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  !controller.useEndDate.value ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: !controller.useEndDate.value ? color : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text('After', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 12),
                Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: controller.recurrenceCount.value > 1 ? () => controller.setRecurrenceCount(controller.recurrenceCount.value - 1) : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 32),
                      ),
                      Expanded(
                        child: Text(
                          '${controller.recurrenceCount.value}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => controller.setRecurrenceCount(controller.recurrenceCount.value + 1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 32),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('occurrences', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // End by date
        InkWell(
          onTap: () async {
            controller.setUseEndDate(true);
            if (controller.recurrenceEndDate.value == null) {
              final picked = await showDatePicker(
                context: context,
                initialDate: controller.startDate.value.add(const Duration(days: 30)),
                firstDate: controller.startDate.value,
                lastDate: DateTime(2100),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: color)),
                  child: child!,
                ),
              );
              if (picked != null) {
                controller.setRecurrenceEndDate(picked);
              }
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: controller.useEndDate.value ? color.withAlpha(15) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: controller.useEndDate.value ? color.withAlpha(100) : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  controller.useEndDate.value ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: controller.useEndDate.value ? color : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text('On', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      controller.setUseEndDate(true);
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
                      if (picked != null) {
                        controller.setRecurrenceEndDate(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.recurrenceEndDate.value != null ? DateFormat('MMM d, yyyy').format(controller.recurrenceEndDate.value!) : 'Select date',
                            style: TextStyle(fontSize: 14, color: controller.recurrenceEndDate.value != null ? Colors.black87 : Colors.grey),
                          ),
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  /// Helper to get ordinal suffix (1st, 2nd, 3rd, 4th, etc.)
  String _getOrdinalSuffix(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}
