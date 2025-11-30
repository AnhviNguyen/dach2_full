import 'dart:io';
import 'package:flutter/foundation.dart';

class AiApiConfig {
  // Base URL cho AI backend (FastAPI)
  // 
  // CÁCH SỬ DỤNG:
  // 1. Thiết bị thật (mặc định): http://192.168.1.134:8000/api
  // 2. Android Emulator: Set AI_API_BASE_URL=http://10.0.2.2:8000/api khi chạy
  // 3. iOS Simulator: http://localhost:8000/api (tự động)
  // 4. Web: http://localhost:8000/api (tự động)
  //
  // LƯU Ý: Sau khi sửa IP, cần REBUILD app (không phải hot reload):
  //   flutter clean
  //   flutter run
  static String get baseUrl {
    // Ưu tiên: Nếu có set AI_API_BASE_URL từ command line, dùng nó
    final envUrl = const String.fromEnvironment('AI_API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Auto-detect platform
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://192.168.1.101:8000/api';
    } else if (Platform.isIOS) {
      // iOS simulator có thể dùng localhost
      // Nếu chạy trên thiết bị thật, set AI_API_BASE_URL với IP máy host
      return 'http://localhost:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
  }

  // Timeout settings - Tăng timeout cho AI processing (đặc biệt cho pronunciation model)
  static const Duration connectTimeout = Duration(seconds: 180);
  static const Duration receiveTimeout = Duration(seconds: 180);
  static const Duration sendTimeout = Duration(seconds: 180);

  // AI API Endpoints
  static const String topikExams = '/topik/exams';
  static const String topikQuestions = '/topik/exams/{examNumber}/questions';
  static const String topikQuestion = '/topik/exams/{examNumber}/questions/{questionId}';
  static const String topikQuestionByNumber = '/topik/exams/{examNumber}/questions/number/{number}';
  static const String topikQuestionVocabulary = '/topik/exams/{examNumber}/questions/{questionId}/vocabulary';
  static const String topikStats = '/topik/stats';
  static const String topikCompetitionQuestions = '/topik/competition/questions';
  
  static const String speakingReadAloud = '/speaking/read-aloud';
  static const String speakingFreeSpeak = '/speaking/free-speak';
  static const String speakingModelStatus = '/speaking/model-status';
  static const String speakingPhrases = '/speaking/phrases';
  
  static const String liveTalkTurn = '/live-talk/turn';
  static const String liveTalkMission = '/live-talk/mission';
  static const String liveTalkEndSession = '/live-talk/end-session';
  
  static const String chatTeacher = '/chat-teacher';
  static const String tts = '/tts';
  
  // User Progress endpoints
  static const String userSaveWeakWord = '/user/save-weak-word';
  static const String userWeakWords = '/user/weak-words';
  static const String userSavePhrase = '/user/save-phrase';
  static const String userPhrases = '/user/phrases';
  static const String userProgress = '/user/progress';

  // Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerMultipartFormData = 'multipart/form-data';
}

