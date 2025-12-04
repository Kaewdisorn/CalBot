/// Generic API Response wrapper
/// Provides a consistent structure for all API responses
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  // Private constructor
  ApiResponse._({this.data, this.error, this.statusCode, required this.isSuccess});

  // ============ Factory Constructors ============

  /// Create a success response with data
  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data, isSuccess: true);
  }

  /// Create an error response
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse._(error: message, statusCode: statusCode, isSuccess: false);
  }

  // ============ Helper Methods ============

  /// Check if response has data
  bool get hasData => data != null;

  /// Check if response has error
  bool get hasError => error != null;

  /// Get data or throw if error
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception(error ?? 'No data available');
  }

  /// Transform data if success
  ApiResponse<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      return ApiResponse.success(transform(data as T));
    }
    return ApiResponse.error(error ?? 'Unknown error', statusCode: statusCode);
  }

  /// Execute callback based on success/error
  void when({required void Function(T data) success, required void Function(String error) failure}) {
    if (isSuccess && data != null) {
      success(data as T);
    } else {
      failure(error ?? 'Unknown error');
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponse.success(data: $data)';
    }
    return 'ApiResponse.error(error: $error, statusCode: $statusCode)';
  }
}
