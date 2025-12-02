import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/auth/data/models/auth_models.dart';

class UserApiService {
  final DioClient _dioClient = DioClient();

  Future<UserModel> getCurrentUser({int? userId}) async {
    try {
      final queryParams = userId != null ? {'userId': userId} : null;
      final response = await _dioClient.get(
        '/auth/me',
        queryParameters: queryParams,
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel> getUserById(int userId) async {
    try {
      final response = await _dioClient.get(
        '/users/$userId',
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel> updateUser(int userId, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put(
        '/users/$userId',
        data: data,
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel> uploadAvatar(int userId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await _dioClient.post(
        '/users/$userId/avatar',
        data: formData,
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

