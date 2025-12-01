import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';

class RoadmapApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Submit survey answers
  Future<Map<String, dynamic>> submitSurvey({
    required int userId,
    required bool hasLearnedKorean,
    required String learningReason,
    required int selfAssessedLevel,
  }) async {
    try {
      final response = await _dioClient.post(
        '/roadmap/survey',
        data: {
          'user_id': userId,
          'has_learned_korean': hasLearnedKorean,
          'learning_reason': learningReason,
          'self_assessed_level': selfAssessedLevel,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get random TOPIK questions for placement test
  Future<Map<String, dynamic>> getPlacementQuestions({
    int count = 8,
  }) async {
    try {
      final response = await _dioClient.get(
        '/roadmap/placement/questions',
        queryParameters: {
          'count': count,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Submit placement test answers and get evaluated level
  Future<Map<String, dynamic>> submitPlacementTest({
    required int userId,
    required Map<String, dynamic> surveyData,
    required List<Map<String, dynamic>> answers,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final response = await _dioClient.post(
        '/roadmap/placement/evaluate',
        data: {
          'user_id': userId,
          'survey_data': surveyData,
          'answers': answers,
          'questions': questions,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get roadmap tasks based on user level
  Future<Map<String, dynamic>> getRoadmapTasks({
    required int userId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/roadmap/tasks',
        queryParameters: {
          'user_id': userId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update task completion status
  Future<Map<String, dynamic>> updateTaskStatus({
    required int userId,
    required String taskId,
    required bool completed,
    String? roadmapId,
    int? current,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'task_id': taskId,
        'completed': completed,
      };
      
      if (roadmapId != null) {
        data['roadmap_id'] = roadmapId;
      }
      
      if (current != null) {
        data['current'] = current;
      }
      
      final response = await _dioClient.post(
        '/roadmap/tasks/update',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get user roadmap level and progress
  Future<Map<String, dynamic>> getUserRoadmap({
    required int userId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/roadmap/user/$userId',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Generate roadmap with timeline based on goals
  Future<Map<String, dynamic>> generateRoadmap({
    required int userId,
    required int currentLevel,
    required int targetLevel,
    required int timelineMonths,
    int? timelineDays,  // Optional: actual days (takes precedence)
    required Map<String, dynamic> surveyData,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'current_level': currentLevel,
        'target_level': targetLevel,
        'timeline_months': timelineMonths,
        'survey_data': surveyData,
      };
      
      // If timelineDays is provided, use it instead of calculating from months
      if (timelineDays != null) {
        data['timeline_days'] = timelineDays;
      }
      
      final response = await _dioClient.post(
        '/roadmap/generate',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get roadmap timeline with progress from database
  Future<Map<String, dynamic>> getRoadmapTimeline({
    required int userId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/roadmap/timeline/$userId',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

