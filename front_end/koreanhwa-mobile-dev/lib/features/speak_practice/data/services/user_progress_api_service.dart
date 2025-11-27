import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/config/ai_api_config.dart';

class UserProgressApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Save a weak word (word that user struggles with)
  /// 
  /// [userId] - User identifier
  /// [word] - The problematic word
  /// [errorType] - Type of error: 'substitution', 'deletion', or 'mispronunciation'
  /// [errorCount] - Number of times mispronounced (default: 1)
  /// [lastPracticed] - ISO timestamp of last practice
  Future<Map<String, dynamic>> saveWeakWord({
    required String userId,
    required String word,
    required String errorType, // 'substitution', 'deletion', 'mispronunciation'
    int errorCount = 1,
    required String lastPracticed, // ISO timestamp
  }) async {
    try {
      final formData = {
        'user_id': userId,
        'word': word,
        'error_type': errorType,
        'error_count': errorCount,
        'last_practiced': lastPracticed,
      };

      final response = await _dioClient.postFormData(
        '/api/user/save-weak-word',
        formData: FormData.fromMap(formData),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get user's weak words for focused practice
  /// 
  /// [userId] - User identifier
  /// [limit] - Maximum number of weak words to return (default: 5)
  Future<Map<String, dynamic>> getWeakWords({
    required String userId,
    int limit = 5,
  }) async {
    try {
      final response = await _dioClient.get(
        '/api/user/weak-words',
        queryParameters: {
          'user_id': userId,
          'limit': limit,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Save a phrase to user's personal bank
  /// 
  /// [userId] - User identifier
  /// [phrase] - The phrase to save
  /// [source] - Where it came from (e.g., 'lesson_1', 'live_talk_travel')
  /// [topic] - Topic category (food, travel, work, etc.)
  /// [savedAt] - ISO timestamp when saved
  Future<Map<String, dynamic>> savePhrase({
    required String userId,
    required String phrase,
    required String source,
    required String topic,
    required String savedAt, // ISO timestamp
  }) async {
    try {
      final formData = {
        'user_id': userId,
        'phrase': phrase,
        'source': source,
        'topic': topic,
        'saved_at': savedAt,
      };

      final response = await _dioClient.postFormData(
        '/api/user/save-phrase',
        formData: FormData.fromMap(formData),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get user's saved phrases, optionally filtered by topic
  /// 
  /// [userId] - User identifier
  /// [topic] - Optional topic filter (food, travel, work, etc.)
  Future<Map<String, dynamic>> getPhrases({
    required String userId,
    String? topic,
  }) async {
    try {
      final response = await _dioClient.get(
        '/api/user/phrases',
        queryParameters: {
          'user_id': userId,
          if (topic != null) 'topic': topic,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get aggregate user progress data
  /// 
  /// [userId] - User identifier
  Future<Map<String, dynamic>> getUserProgress({
    required String userId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/api/user/progress',
        queryParameters: {
          'user_id': userId,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

