import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/config/ai_api_config.dart';

class TopikApiService {
  final AiDioClient _dioClient = AiDioClient();

  /// Lấy danh sách tất cả các kỳ thi TOPIK có sẵn
  Future<Map<String, dynamic>> getExams() async {
    try {
      final response = await _dioClient.get(AiApiConfig.topikExams);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy câu hỏi TOPIK cho một kỳ thi cụ thể
  /// 
  /// [examNumber] - Số kỳ thi (ví dụ: "35", "36", "37")
  /// [questionType] - Loại câu hỏi: "listening" hoặc "reading"
  /// [limit] - Số lượng câu hỏi tối đa (tùy chọn)
  /// [offset] - Offset cho phân trang (mặc định: 0)
  Future<Map<String, dynamic>> getTopikQuestions({
    required String examNumber,
    required String questionType, // "listening" hoặc "reading"
    int? limit,
    int offset = 0,
  }) async {
    try {
      final path = AiApiConfig.topikQuestions
          .replaceAll('{examNumber}', examNumber);
      
      final response = await _dioClient.get(
        path,
        queryParameters: {
          'question_type': questionType,
          if (limit != null) 'limit': limit,
          'offset': offset,
        },
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy một câu hỏi TOPIK cụ thể theo ID
  Future<Map<String, dynamic>> getTopikQuestion({
    required String examNumber,
    required String questionId,
    required String questionType,
  }) async {
    try {
      final path = AiApiConfig.topikQuestion
          .replaceAll('{examNumber}', examNumber)
          .replaceAll('{questionId}', questionId);
      
      final response = await _dioClient.get(
        path,
        queryParameters: {
          'question_type': questionType,
        },
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy một câu hỏi TOPIK theo số thứ tự
  Future<Map<String, dynamic>> getTopikQuestionByNumber({
    required String examNumber,
    required int number,
    required String questionType,
  }) async {
    try {
      final path = AiApiConfig.topikQuestionByNumber
          .replaceAll('{examNumber}', examNumber)
          .replaceAll('{number}', number.toString());
      
      final response = await _dioClient.get(
        path,
        queryParameters: {
          'question_type': questionType,
        },
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy từ vựng từ một câu hỏi TOPIK và dịch bằng dictionary
  Future<Map<String, dynamic>> getQuestionVocabulary({
    required String examNumber,
    required String questionId,
    required String questionType,
    int maxWords = 50,
  }) async {
    try {
      final path = AiApiConfig.topikQuestionVocabulary
          .replaceAll('{examNumber}', examNumber)
          .replaceAll('{questionId}', questionId);
      
      final response = await _dioClient.get(
        path,
        queryParameters: {
          'question_type': questionType,
          'max_words': maxWords,
        },
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy thống kê về dữ liệu TOPIK có sẵn
  Future<Map<String, dynamic>> getTopikStats() async {
    try {
      final response = await _dioClient.get(AiApiConfig.topikStats);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy câu hỏi TOPIK ngẫu nhiên cho competition
  /// Trả về mix của listening và reading questions từ nhiều đề thi khác nhau
  Future<Map<String, dynamic>> getCompetitionQuestions({
    int count = 20,
    bool mixTypes = true,
  }) async {
    try {
      final response = await _dioClient.get(
        AiApiConfig.topikCompetitionQuestions,
        queryParameters: {
          'count': count,
          'mix_types': mixTypes,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

