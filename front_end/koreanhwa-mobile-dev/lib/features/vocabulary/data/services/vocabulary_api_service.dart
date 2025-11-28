import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';

class VocabularyApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Get vocabulary learning methods for a specific lesson
  Future<Map<String, dynamic>> getVocabularyLearningMethods({
    required int bookId,
    required int lessonId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/vocabulary/learning-methods',
        queryParameters: {
          'book_id': bookId,
          'lesson_id': lessonId,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Submit vocabulary test
  Future<Map<String, dynamic>> submitVocabularyTest({
    required int bookId,
    required int lessonId,
    required Map<String, String> answers,
  }) async {
    try {
      final response = await _dioClient.post(
        '/vocabulary/test/submit',
        queryParameters: {
          'book_id': bookId,
          'lesson_id': lessonId,
        },
        data: answers,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

