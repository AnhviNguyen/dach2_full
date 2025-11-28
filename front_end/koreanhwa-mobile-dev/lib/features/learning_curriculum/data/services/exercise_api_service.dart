import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';

class ExerciseApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Generate exercises for a lesson
  Future<Map<String, dynamic>> generateExercises({
    required int bookId,
    required int lessonId,
    int count = 5,
  }) async {
    try {
      final response = await _dioClient.get(
        '/exercise/generate',
        queryParameters: {
          'book_id': bookId,
          'lesson_id': lessonId,
          'count': count,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

