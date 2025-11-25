import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/models/page_response.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/textbook/data/models/textbook.dart';

class TextbookApiService {
  final DioClient _dioClient = DioClient();

  Future<PageResponse<Textbook>> getTextbooks({
    int page = 0,
    int size = 10,
    String sortBy = 'bookNumber',
    String direction = 'ASC',
  }) async {
    try {
      final response = await _dioClient.get(
        '/curriculum',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'direction': direction,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => Textbook.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Textbook> getTextbookById(int id) async {
    try {
      final response = await _dioClient.get('/curriculum/$id');
      return Textbook.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Textbook> getTextbookByBookNumber(int bookNumber) async {
    try {
      final response = await _dioClient.get('/curriculum/book-number/$bookNumber');
      return Textbook.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Textbook> getTextbookProgress(int textbookId, int userId) async {
    try {
      final response = await _dioClient.get('/curriculum/$textbookId/progress/$userId');
      return Textbook.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

