import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/models/page_response.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_question.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_result.dart';

class CompetitionApiService {
  final DioClient _dioClient = DioClient();

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
      final response = await _dioClient.get('/competitions/$competitionId/questions');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => CompetitionQuestion.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
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

