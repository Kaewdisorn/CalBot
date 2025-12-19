import 'package:flutter/material.dart';
import 'package:halulu/data/models/schedule_model.dart';

import '../../../core/api/api.dart';

/// Repository for Schedule-related API operations
/// This is the single source of truth for schedule data
class ScheduleRepository {
  final ApiClient _apiClient;

  ScheduleRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ============ GET ALL SCHEDULES ============
  Future<ApiResponse<List<ScheduleModel>>> getSchedules({required String gid}) async {
    String endpoint = ApiConfig.schedules;

    if (gid.isNotEmpty) {
      endpoint = '${ApiConfig.schedules}?gid=$gid';

      return await _apiClient.get<List<ScheduleModel>>(
        endpoint,
        parser: (json) {
          // API returns: { "data": [...] } or just [...]
          final List<dynamic> list = json is List ? json : (json['data'] as List? ?? []);
          return list.map((item) => ScheduleModel.fromJson(item as Map<String, dynamic>)).toList();
        },
      );
    } else {
      debugPrint('⚠️ Warning: Fetching all schedules without gid filter');
      return ApiResponse.error('User ID (gid) is required to fetch schedules');
    }
  }

  // ============ GET SINGLE SCHEDULE ============
  /// Fetch a single schedule by ID
  Future<ApiResponse<ScheduleModel>> getScheduleById(String id) async {
    return await _apiClient.get<ScheduleModel>(
      '${ApiConfig.schedules}/$id',
      parser: (json) {
        // API returns: { "data": {...} } or just {...}
        final Map<String, dynamic> data = json is Map<String, dynamic> ? (json['data'] as Map<String, dynamic>? ?? json) : json;
        return ScheduleModel.fromJson(data);
      },
    );
  }

  // ============ CREATE SCHEDULE ============
  // Future<ApiResponse<ScheduleModel>> createSchedule(ScheduleModel schedule) async {
  //   return await _apiClient.post<ScheduleModel>(
  //     ApiConfig.schedules,
  //     body: schedule.toJson(),
  //     parser: (json) {
  //       final Map<String, dynamic> data = json is Map<String, dynamic> ? (json['data'] as Map<String, dynamic>? ?? json) : json;
  //       return ScheduleModel.fromJson(data);
  //     },
  //   );
  // }

  // ============ UPDATE SCHEDULE ============
  /// Update an existing schedule
  Future<ApiResponse<ScheduleModel>> updateSchedule(ScheduleModel schedule) async {
    return await _apiClient.put<ScheduleModel>(
      '${ApiConfig.schedules}/${schedule.uid}',
      body: schedule.toJson(),
      parser: (json) {
        final Map<String, dynamic> data = json is Map<String, dynamic> ? (json['data'] as Map<String, dynamic>? ?? json) : json;
        return ScheduleModel.fromJson(data);
      },
    );
  }

  // ============ DELETE SCHEDULE ============
  /// Delete a schedule by ID (requires userId for ownership validation)
  Future<ApiResponse<bool>> deleteSchedule(String id, {required String userId}) async {
    final response = await _apiClient.delete<dynamic>('${ApiConfig.schedules}/$id?userId=$userId');

    // Convert to bool response
    if (response.isSuccess) {
      return ApiResponse.success(true);
    }
    return ApiResponse.error(response.error ?? 'Delete failed');
  }

  // ============ CLEANUP ============
  void dispose() {
    _apiClient.dispose();
  }
}
