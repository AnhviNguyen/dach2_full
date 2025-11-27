import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/config/ai_api_config.dart';

class TtsApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Generate text-to-speech audio
  /// 
  /// [text] - Text to convert to speech
  /// [lang] - Language code ('ko' for Korean, 'vi' for Vietnamese, 'en' for English)
  ///          If null, language will be auto-detected
  /// 
  /// Returns: { 'audio_url': '/media/filename.mp3', 'text': '...' }
  Future<Map<String, dynamic>> generateSpeech({
    required String text,
    String? lang,
  }) async {
    try {
      final response = await _dioClient.post(
        AiApiConfig.tts,
        data: {
          'text': text,
          if (lang != null) 'lang': lang,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get full URL for media file
  /// 
  /// [audioUrl] - Audio URL from TTS response (e.g., '/media/filename.mp3')
  String getMediaUrl(String audioUrl) {
    // Remove leading slash if present
    final cleanUrl = audioUrl.startsWith('/') ? audioUrl.substring(1) : audioUrl;
    // Base URL without /api suffix
    final baseUrl = AiApiConfig.baseUrl.replaceAll('/api', '');
    return '$baseUrl/$cleanUrl';
  }
}

