import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/models/page_response.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/material/data/models/learning_material.dart';

class MaterialApiService {
  final DioClient _dioClient = DioClient();

  Future<PageResponse<LearningMaterial>> getMaterials({
    int page = 0,
    int size = 100,
    String sortBy = 'id',
    String direction = 'ASC',
    int? currentUserId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/materials',
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
        (json) => LearningMaterial.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PageResponse<LearningMaterial>> getMaterialsByFilters({
    String? level,
    String? skill,
    String? type,
    String? searchQuery,
    int page = 0,
    int size = 100,
    int? currentUserId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/materials/filter',
        queryParameters: {
          if (level != null && level != 'all') 'level': level,
          if (skill != null && skill != 'all') 'skill': skill,
          if (type != null && type != 'all') 'type': type,
          if (searchQuery != null && searchQuery.isNotEmpty) 'searchQuery': searchQuery,
          'page': page,
          'size': size,
          if (currentUserId != null) 'currentUserId': currentUserId,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LearningMaterial.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LearningMaterial> getMaterialById(int id, {int? currentUserId}) async {
    try {
      final response = await _dioClient.get(
        '/materials/$id',
        queryParameters: {
          if (currentUserId != null) 'currentUserId': currentUserId,
        },
      );
      return LearningMaterial.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<LearningMaterial>> getFeaturedMaterials({int? currentUserId}) async {
    try {
      final response = await _dioClient.get(
        '/materials/featured',
        queryParameters: {
          if (currentUserId != null) 'currentUserId': currentUserId,
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => LearningMaterial.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<int> getDownloadedMaterialsCount(int userId) async {
    try {
      final response = await _dioClient.get(
        '/materials/downloads/count',
        queryParameters: {'userId': userId},
      );
      return response.data as int;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LearningMaterial> downloadMaterial(int materialId, int userId) async {
    try {
      final response = await _dioClient.post(
        '/materials/$materialId/download',
        queryParameters: {'userId': userId},
      );
      return LearningMaterial.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<int> getTotalMaterialsCount() async {
    try {
      final response = await _dioClient.get('/materials/count');
      return response.data as int;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

