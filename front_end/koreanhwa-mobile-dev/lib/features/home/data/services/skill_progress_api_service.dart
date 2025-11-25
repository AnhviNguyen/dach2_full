import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/home/data/models/skill_progress.dart';

class SkillProgressApiService {
  final DioClient _dioClient = DioClient();

  Future<List<SkillProgress>> getUserSkillProgress(int userId) async {
    try {
      final response = await _dioClient.get('/skills/user/$userId');
      return (response.data as List<dynamic>)
          .map((item) => SkillProgress.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

