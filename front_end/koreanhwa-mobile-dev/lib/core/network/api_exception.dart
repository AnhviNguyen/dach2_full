import 'package:dio/dio.dart';

/// Custom exception cho API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;

  factory ApiException.fromDioException(dynamic error) {
    if (error is DioException) {
      String message = 'Đã xảy ra lỗi';
      dynamic responseData = error.response?.data;

      // Extract message from backend response
      if (responseData != null) {
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] as String? ?? 
                   responseData['error'] as String? ?? 
                   responseData['status']?.toString() ?? 
                   message;
        } else if (responseData is String) {
          message = responseData;
        }
      }

      // Fallback to error message if no response data
      if (message == 'Đã xảy ra lỗi' && error.error != null) {
        message = error.error.toString();
      }

      // Fallback to error message if still default
      if (message == 'Đã xảy ra lỗi' && error.message != null) {
        message = error.message!;
      }

      return ApiException(
        message: message,
        statusCode: error.response?.statusCode,
        originalError: error,
      );
    }
    return ApiException(
      message: error.toString(),
      originalError: error,
    );
  }
}

