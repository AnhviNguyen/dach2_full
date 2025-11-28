import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';

class ProgressApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Save lesson progress
  Future<Map<String, dynamic>> saveProgress({
    required int userId,
    required int bookId,
    required int lessonId,
    bool completed = true,
  }) async {
    try {
      final response = await _dioClient.post(
        '/progress/save',
        queryParameters: {
          'user_id': userId,
          'book_id': bookId,
          'lesson_id': lessonId,
          'completed': completed,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

