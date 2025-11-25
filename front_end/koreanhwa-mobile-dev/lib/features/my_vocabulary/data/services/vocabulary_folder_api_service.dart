import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/models/vocabulary_folder_model.dart';

class VocabularyFolderApiService {
  final DioClient _dioClient = DioClient();

  Future<List<VocabularyFolder>> getFoldersByUserId(int userId) async {
    try {
      final response = await _dioClient.get(
        '/vocabulary-folders',
        queryParameters: {'userId': userId},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => VocabularyFolder.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<VocabularyFolder> getFolderById(int folderId, int userId) async {
    try {
      final response = await _dioClient.get(
        '/vocabulary-folders/$folderId',
        queryParameters: {'userId': userId},
      );
      return VocabularyFolder.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<VocabularyFolder> createFolder({
    required String name,
    String icon = '📁',
    required int userId,
  }) async {
    try {
      final response = await _dioClient.post(
        '/vocabulary-folders',
        data: {
          'name': name,
          'icon': icon,
        },
        queryParameters: {'userId': userId},
      );
      return VocabularyFolder.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<VocabularyFolder> updateFolder({
    required int folderId,
    required String name,
    String? icon,
    required int userId,
  }) async {
    try {
      final response = await _dioClient.put(
        '/vocabulary-folders/$folderId',
        data: {
          'name': name,
          if (icon != null) 'icon': icon,
        },
        queryParameters: {'userId': userId},
      );
      return VocabularyFolder.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteFolder(int folderId, int userId) async {
    try {
      await _dioClient.delete(
        '/vocabulary-folders/$folderId',
        queryParameters: {'userId': userId},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<VocabularyWord> addWordToFolder({
    required int folderId,
    required String korean,
    required String vietnamese,
    String? pronunciation,
    String? example,
    required int userId,
  }) async {
    try {
      final response = await _dioClient.post(
        '/vocabulary-folders/$folderId/words',
        data: {
          'korean': korean,
          'vietnamese': vietnamese,
          if (pronunciation != null) 'pronunciation': pronunciation,
          if (example != null) 'example': example,
        },
        queryParameters: {'userId': userId},
      );
      return VocabularyWord.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<VocabularyWord> updateWord({
    required int wordId,
    required String korean,
    required String vietnamese,
    String? pronunciation,
    String? example,
    required int userId,
  }) async {
    try {
      final response = await _dioClient.put(
        '/vocabulary-folders/words/$wordId',
        data: {
          'korean': korean,
          'vietnamese': vietnamese,
          if (pronunciation != null) 'pronunciation': pronunciation,
          if (example != null) 'example': example,
        },
        queryParameters: {'userId': userId},
      );
      return VocabularyWord.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteWord(int wordId, int userId) async {
    try {
      await _dioClient.delete(
        '/vocabulary-folders/words/$wordId',
        queryParameters: {'userId': userId},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

