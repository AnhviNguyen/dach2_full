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

  /// Lookup vocabulary word (tra từ điển)
  Future<Map<String, dynamic>> lookupWord(String word) async {
    try {
      final response = await _dioClient.get(
        '/vocabulary/lookup',
        queryParameters: {'word': word},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Add word to daily folder (thêm từ vào folder theo ngày)
  Future<Map<String, dynamic>> addWordToDailyFolder({
    required int userId,
    required String word,
    required String vietnamese,
    String? pronunciation,
    String? example,
    String? dateStr,
  }) async {
    try {
      final formData = FormData.fromMap({
        'user_id': userId,
        'word': word,
        'vietnamese': vietnamese,
        if (pronunciation != null && pronunciation.isNotEmpty) 'pronunciation': pronunciation,
        if (example != null && example.isNotEmpty) 'example': example,
        if (dateStr != null && dateStr.isNotEmpty) 'date_str': dateStr,
      });

      final response = await _dioClient.postFormData(
        '/vocabulary/add-to-daily-folder',
        formData: formData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

