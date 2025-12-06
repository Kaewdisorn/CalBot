import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/schedule_model.dart';
import '../repositories/schedule_repository.dart';

class HomeController extends GetxController {
  final List<CalendarView> allowedViews = <CalendarView>[CalendarView.month, CalendarView.schedule];

  // Repository for API calls
  final ScheduleRepository _repository = ScheduleRepository();

  // Observable schedule list — populated from API
  final RxList<ScheduleModel> scheduleList = <ScheduleModel>[].obs;
  final RxBool isAgendaView = false.obs;

  // Current user ID for ownership validation
  // TODO: Replace with actual user authentication
  final RxnString currentUserId = RxnString('user_001');

  // Loading and error states
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString(null);

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
  }

  @override
  void onClose() {
    _repository.dispose();
    super.onClose();
  }

  // ============ FETCH ALL SCHEDULES ============
  /// Fetch schedules for current user
  Future<void> fetchSchedules() async {
    isLoading.value = true;
    errorMessage.value = null;

    final response = await _repository.getSchedules(userId: currentUserId.value);

    response.when(
      success: (data) {
        scheduleList.assignAll(data);
        debugPrint('✅ Loaded ${data.length} schedules for user: ${currentUserId.value}');
      },
      failure: (error) {
        errorMessage.value = error;
        debugPrint('❌ Failed to load schedules: $error');
        // Optionally show snackbar
        Get.snackbar('Error', error, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      },
    );

    isLoading.value = false;
  }

  // ============ CREATE SCHEDULE ============
  /// Add new schedule via API
  Future<bool> createSchedule(ScheduleModel schedule) async {
    isLoading.value = true;

    final response = await _repository.createSchedule(schedule);

    bool success = false;
    response.when(
      success: (data) {
        scheduleList.add(data);
        debugPrint('✅ Created schedule: ${data.title}');
        success = true;
      },
      failure: (error) {
        debugPrint('❌ Failed to create schedule: $error');
        Get.snackbar(
          'Error',
          'Failed to create schedule: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      },
    );

    isLoading.value = false;
    return success;
  }

  // ============ UPDATE SCHEDULE ============
  /// Update existing schedule via API
  Future<bool> updateSchedule(ScheduleModel schedule) async {
    isLoading.value = true;

    final response = await _repository.updateSchedule(schedule);

    bool success = false;
    response.when(
      success: (data) {
        final index = scheduleList.indexWhere((s) => s.uid == data.uid);
        if (index != -1) {
          scheduleList[index] = data;
        }
        debugPrint('✅ Updated schedule: ${data.title}');
        success = true;
      },
      failure: (error) {
        debugPrint('❌ Failed to update schedule: $error');
        Get.snackbar(
          'Error',
          'Failed to update schedule: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      },
    );

    isLoading.value = false;
    return success;
  }

  // ============ DELETE SCHEDULE ============
  /// Delete schedule via API
  Future<bool> deleteSchedule(String id) async {
    isLoading.value = true;

    // Require userId for deletion
    if (currentUserId.value == null) {
      debugPrint('❌ Cannot delete schedule: No user logged in');
      Get.snackbar(
        'Error',
        'You must be logged in to delete schedules',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return false;
    }

    final response = await _repository.deleteSchedule(id, userId: currentUserId.value!);

    bool success = false;
    response.when(
      success: (_) {
        scheduleList.removeWhere((s) => s.uid == id);
        debugPrint('✅ Deleted schedule: $id');
        success = true;
      },
      failure: (error) {
        debugPrint('❌ Failed to delete schedule: $error');
        Get.snackbar(
          'Error',
          'Failed to delete schedule: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      },
    );

    isLoading.value = false;
    return success;
  }

  // ============ LOCAL OPERATIONS ============
  // These update the local list immediately for responsive UI
  // Call the API methods above when you want to persist changes

  /// Add schedule to local list (for optimistic updates)
  void addScheduleLocal(ScheduleModel schedule) {
    scheduleList.add(schedule);
  }

  /// Update schedule in local list (for optimistic updates)
  void updateScheduleLocal(ScheduleModel schedule) {
    final index = scheduleList.indexWhere((s) => s.uid == schedule.uid);
    if (index != -1) {
      scheduleList[index] = schedule;
    }
  }

  /// Remove schedule from local list (for optimistic updates)
  void removeScheduleLocal(String uid) {
    scheduleList.removeWhere((s) => s.uid == uid);
  }
}
