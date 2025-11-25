import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/models/page_response.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/ranking/data/models/ranking_entry.dart';

class RankingApiService {
  final DioClient _dioClient = DioClient();

  Future<PageResponse<RankingEntry>> getRankings({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        '/rankings',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => RankingEntry.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<RankingEntry>> getAllRankings() async {
    try {
      final response = await _dioClient.get('/rankings/all');
      return (response.data as List<dynamic>)
          .map((item) => RankingEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<RankingEntry> getRankingByUserId(int userId) async {
    try {
      final response = await _dioClient.get('/rankings/user/$userId');
      return RankingEntry.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

