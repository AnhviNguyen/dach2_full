import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/config/ai_api_config.dart';

class ChatApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Chat with AI teacher
  /// 
  /// [message] - User's message
  /// [mode] - Chat mode: 'free_chat', 'explain', or 'speaking_feedback'
  /// [language] - Language code (default: 'ko')
  /// [history] - Optional conversation history
  Future<Map<String, dynamic>> chatWithTeacher({
    required String message,
    String mode = 'free_chat',
    String language = 'ko',
    List<Map<String, String>>? history,
  }) async {
    try {
      final response = await _dioClient.post(
        AiApiConfig.chatTeacher,
        data: {
          'message': message,
          'mode': mode,
          'language': language,
          if (history != null) 'history': history,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

