import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halulu/data/models/schedule_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../api/api_config.dart';
import '../api/api_requester.dart';
import '../data/repositories/schedule_repository.dart';
import 'widgets_controller/auth_controller.dart';

class HomeController extends GetxController {
  final _apiRequester = ApiRequester();
  final List<CalendarView> allowedViews = <CalendarView>[CalendarView.month, CalendarView.schedule];
  final ScheduleRepository _repository = ScheduleRepository();
  final RxList<ScheduleModel> scheduleList = <ScheduleModel>[].obs;
  final RxBool isAgendaView = false.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString(null);

  final AuthController _authController = Get.find<AuthController>();

  // Current user ID from auth controller
  String? get userUid => _authController.userUid.value.isNotEmpty ? _authController.userUid.value : null;
  String? get userGid => _authController.userGid.value.isNotEmpty ? _authController.userGid.value : null;

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
  Future<void> fetchSchedules() async {
    isLoading.value = true;
    errorMessage.value = null;

    if (userGid == null) {
      errorMessage.value = 'No user logged in';
      isLoading.value = false;
      debugPrint('⚠️ Cannot fetch schedules: No user logged in');
      return;
    }

    debugPrint('🔑 Fetching schedules for user: $userGid');

    final response = await _repository.getSchedules(gid: userGid!);

    response.when(
      success: (data) {
        scheduleList.assignAll(data);
        debugPrint('✅ Loaded ${data.length} schedules for user: $userGid');
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
  Future<bool> createSchedule(ScheduleModel schedule) async {
    isLoading.value = true;
    final response = await _apiRequester.post(endpoint: ApiConfig.scheduleUrl, body: schedule.toJson());
    debugPrint('Response from createSchedule: $response');

    // final response = await _repository.createSchedule(schedule);

    bool success = false;
    // response.when(
    //   success: (data) {
    //     scheduleList.add(data);
    //     debugPrint('✅ Created schedule: ${data.title}');
    //     success = true;
    //   },
    //   failure: (error) {
    //     debugPrint('❌ Failed to create schedule: $error');
    //     Get.snackbar(
    //       'Error',
    //       'Failed to create schedule: $error',
    //       snackPosition: SnackPosition.BOTTOM,
    //       backgroundColor: Colors.redAccent,
    //       colorText: Colors.white,
    //     );
    //   },
    // );

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
    if (userGid == null) {
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

    final response = await _repository.deleteSchedule(id, userId: userGid!);

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
