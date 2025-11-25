import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/models/page_response.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/achievements/data/models/achievement_item.dart';

class AchievementApiService {
  final DioClient _dioClient = DioClient();

  Future<PageResponse<AchievementItem>> getAchievements({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String direction = 'ASC',
  }) async {
    try {
      final response = await _dioClient.get(
        '/achievements',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'direction': direction,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => AchievementItem.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<AchievementItem>> getUserAchievements(int userId) async {
    try {
      final response = await _dioClient.get('/achievements/user/$userId');
      return (response.data as List<dynamic>)
          .map((item) => AchievementItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AchievementItem> getUserAchievement(int userId, int achievementId) async {
    try {
      final response = await _dioClient.get('/achievements/user/$userId/achievement/$achievementId');
      return AchievementItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

