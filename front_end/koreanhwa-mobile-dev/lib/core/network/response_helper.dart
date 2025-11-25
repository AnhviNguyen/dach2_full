import 'package:dio/dio.dart';

/// Helper class để parse response an toàn
class ResponseHelper {
  /// Parse response data an toàn với null safety
  static Map<String, dynamic>? parseJsonResponse(Response response) {
    try {
      if (response.data == null) {
        return null;
      }
      
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      
      if (response.data is String) {
        // Nếu là string, có thể là JSON string
        return null; // Cần parse JSON string nếu cần
      }
      
      return null;
    } catch (e) {
      print('❌ Error parsing response: $e');
      print('   Response data type: ${response.data.runtimeType}');
      print('   Response data: ${response.data}');
      return null;
    }
  }

  /// Parse list response an toàn
  static List<dynamic>? parseListResponse(Response response) {
    try {
      if (response.data == null) {
        return null;
      }
      
      if (response.data is List<dynamic>) {
        return response.data as List<dynamic>;
      }
      
      // Nếu backend trả về object có field chứa list
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        // Thử các key phổ biến
        if (data.containsKey('content')) {
          final content = data['content'];
          if (content is List<dynamic>) {
            return content;
          }
        }
        if (data.containsKey('data')) {
          final content = data['data'];
          if (content is List<dynamic>) {
            return content;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error parsing list response: $e');
      print('   Response data type: ${response.data.runtimeType}');
      print('   Response data: ${response.data}');
      return null;
    }
  }

  /// Kiểm tra response có lỗi không
  static bool hasError(Response response) {
    final statusCode = response.statusCode;
    return statusCode == null || statusCode < 200 || statusCode >= 300;
  }
}

