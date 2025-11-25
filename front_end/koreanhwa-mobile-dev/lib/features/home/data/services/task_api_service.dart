import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/home/data/models/task_item.dart';

class TaskApiService {
  final DioClient _dioClient = DioClient();

  Future<List<TaskItem>> getUserTasks(int userId) async {
    try {
      final response = await _dioClient.get('/tasks/user/$userId');
      return (response.data as List<dynamic>)
          .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

