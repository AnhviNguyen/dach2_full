import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/models/page_response.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_question.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_result.dart';
import 'package:koreanhwa_flutter/features/topik/data/services/topik_api_service.dart';

class CompetitionApiService {
  final DioClient _dioClient = DioClient();
  final TopikApiService _topikApiService = TopikApiService();

  Future<PageResponse<Competition>> getCompetitions({
    int page = 0,
    int size = 100,
    String sortBy = 'id',
    String direction = 'ASC',
    int? currentUserId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/competitions',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'direction': direction,
          if (currentUserId != null) 'currentUserId': currentUserId,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => Competition.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PageResponse<Competition>> getCompetitionsByStatus(
    String status, {
    int page = 0,
    int size = 100,
    int? currentUserId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/competitions/status/$status',
        queryParameters: {
          'page': page,
          'size': size,
          if (currentUserId != null) 'currentUserId': currentUserId,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => Competition.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Competition> getCompetitionById(int id, {int? currentUserId}) async {
    try {
      final response = await _dioClient.get(
        '/competitions/$id',
        queryParameters: {
          if (currentUserId != null) 'currentUserId': currentUserId,
        },
      );
      return Competition.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<CompetitionQuestion>> getCompetitionQuestions(int competitionId) async {
    try {
      // Lấy câu hỏi từ AI backend (TOPIK questions - listening + reading lẫn lộn)
      final response = await _topikApiService.getCompetitionQuestions(
        count: 20, // Số lượng câu hỏi mặc định
        mixTypes: true, // Mix listening và reading
        mixLevels: true, // Mix TOPIK 1 và TOPIK 2
      );
      
      final questionsData = response['questions'] as List<dynamic>? ?? [];
      
      // Convert TOPIK format sang CompetitionQuestion format
      return questionsData.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value as Map<String, dynamic>;
        
        // Tạo unique ID cho competition question
        final questionId = q['question_id'] as String? ?? '';
        final number = q['number'] as int? ?? (index + 1);
        final examNumber = q['exam_number'] as String? ?? '';
        
        // Parse answers
        final answers = q['answers'] as List<dynamic>? ?? [];
        final options = answers.map((ans) {
          if (ans is Map<String, dynamic>) {
            return ans['text'] as String? ?? '';
          }
          return ans.toString();
        }).toList();
        
        // Tìm đáp án đúng
        int correctAnswer = 0;
        for (int i = 0; i < answers.length; i++) {
          if (answers[i] is Map<String, dynamic>) {
            final ans = answers[i] as Map<String, dynamic>;
            if (ans['is_correct'] == true || ans['isCorrect'] == true) {
              correctAnswer = i;
              break;
            }
          }
        }
        
        // Parse question text
        final prompt = q['prompt'] as String? ?? '';
        final introText = q['intro_text'] as String? ?? '';
        final questionText = prompt.isNotEmpty ? prompt : introText;
        
        // Parse audio URL
        final audioUrl = q['audio_url'] as String? ?? 
                         q['context']?['audio'] as String? ?? '';
        
        // Parse question type
        final questionType = q['question_type'] as String? ?? 'reading';
        final category = questionType == 'listening' ? 'Listening' : 'Reading';
        final categoryKr = questionType == 'listening' ? '듣기' : '읽기';
        
        // Generate ID
        final id = questionId.isNotEmpty 
            ? int.tryParse(questionId.replaceAll(RegExp(r'[^0-9]'), '')) ?? (index + 1000)
            : (index + 1000);
        
        return CompetitionQuestion(
          id: id,
          category: category,
          categoryKr: categoryKr,
          title: '',
          titleKr: '',
          audioUrl: audioUrl,
          duration: '30s',
          transcript: introText,
          question: questionText,
          questionKr: questionText,
          options: options,
          correctAnswer: correctAnswer,
        );
      }).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: 'Lỗi tải câu hỏi: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<Competition> joinCompetition(int competitionId, int userId) async {
    try {
      final response = await _dioClient.post(
        '/competitions/$competitionId/join',
        queryParameters: {'userId': userId},
      );
      return Competition.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<CompetitionResult> submitCompetition({
    required int competitionId,
    required Map<int, String> answers,
    required int userId,
  }) async {
    try {
      final response = await _dioClient.post(
        '/competitions/submit',
        data: {
          'competitionId': competitionId,
          'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
        },
        queryParameters: {'userId': userId},
      );
      return CompetitionResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<CompetitionResult> getCompetitionResult(int competitionId, int userId) async {
    try {
      final response = await _dioClient.get(
        '/competitions/$competitionId/result',
        queryParameters: {'userId': userId},
      );
      return CompetitionResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

