import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';

class ChatApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Chat with AI teacher
  Future<Map<String, dynamic>> chatWithTeacher({
    required String message,
    String mode = 'free_chat',
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await _dioClient.post(
        '/chat-teacher',
        data: {
          'message': message,
          'mode': mode,
          'context': context,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

