import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/config/ai_api_config.dart';

class SpeakingApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Đánh giá phát âm khi đọc to
  /// 
  /// [audioFile] - File audio (webm, mp3, wav)
  /// [expectedText] - Văn bản tiếng Hàn người dùng cần đọc
  /// [language] - Mã ngôn ngữ (mặc định: "ko")
  Future<Map<String, dynamic>> checkReadAloud({
    required File audioFile,
    required String expectedText,
    String language = 'ko',
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
        'expected_text': expectedText,
        'language': language,
      });

      final response = await _dioClient.postFormData(
        AiApiConfig.speakingReadAloud,
        formData: formData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Đánh giá phát âm từ audio bytes (cho web hoặc memory)
  Future<Map<String, dynamic>> checkReadAloudFromBytes({
    required List<int> audioBytes,
    required String expectedText,
    required String filename,
    String language = 'ko',
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': MultipartFile.fromBytes(
          audioBytes,
          filename: filename,
        ),
        'expected_text': expectedText,
        'language': language,
      });

      final response = await _dioClient.postFormData(
        AiApiConfig.speakingReadAloud,
        formData: formData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Kiểm tra trạng thái model pronunciation
  Future<Map<String, dynamic>> getModelStatus() async {
    try {
      final response = await _dioClient.get(AiApiConfig.speakingModelStatus);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Đánh giá nói tự do (free-form speaking)
  Future<Map<String, dynamic>> checkFreeSpeaking({
    required File audioFile,
    String? context,
    String language = 'ko',
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
        'language': language,
        if (context != null) 'context': context,
      });

      final response = await _dioClient.postFormData(
        AiApiConfig.speakingFreeSpeak,
        formData: formData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Xử lý một lượt trò chuyện Live Talk
  Future<Map<String, dynamic>> liveTalkTurn({
    required File audioFile,
    required String userId,
    String coachId = 'ivy',
    String? topic,
    List<Map<String, String>>? history,
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
        'user_id': userId,
        'coach_id': coachId,
        if (topic != null) 'topic': topic,
        'history': history != null 
            ? jsonEncode(history)
            : '[]',
      });

      final response = await _dioClient.postFormData(
        AiApiConfig.liveTalkTurn,
        formData: formData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy mission cho một topic cụ thể
  Future<Map<String, dynamic>> getLiveTalkMission({
    String topic = 'daily_life',
  }) async {
    try {
      final response = await _dioClient.get(
        AiApiConfig.liveTalkMission,
        queryParameters: {'topic': topic},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Kết thúc phiên Live Talk và lấy summary
  Future<Map<String, dynamic>> endLiveTalkSession({
    required List<Map<String, String>> history,
    required String topic,
    required String userId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'history': jsonEncode(history),
        'topic': topic,
        'user_id': userId,
      });

      final response = await _dioClient.postFormData(
        AiApiConfig.liveTalkEndSession,
        formData: formData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

