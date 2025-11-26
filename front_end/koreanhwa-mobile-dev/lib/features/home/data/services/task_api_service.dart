import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/home/data/models/task_item.dart';

class TaskApiService {
  final DioClient _dioClient = DioClient();

  Future<List<TaskItem>> getUserTasks(int userId) async {
    try {
      final response = await _dioClient.get('/tasks/user/$userId');
      final tasks = (response.data as List<dynamic>)
          .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
          .toList();
      
      // If no tasks or less than 4, generate daily tasks
      if (tasks.length < 4) {
        await _generateDailyTasks(userId);
        // Reload tasks
        final reloadResponse = await _dioClient.get('/tasks/user/$userId');
        return (reloadResponse.data as List<dynamic>)
            .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      return tasks;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> _generateDailyTasks(int userId) async {
    try {
      await _dioClient.post('/tasks/generate-daily/$userId');
    } on DioException catch (e) {
      // Silently fail - tasks might already exist
    }
  }

  Future<void> updateTaskProgress(int taskId, double progress) async {
    try {
      await _dioClient.put('/tasks/$taskId/progress', data: {'progress': progress});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

