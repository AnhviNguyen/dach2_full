import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/models/page_response.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/courses/data/models/course_info.dart';
import 'package:koreanhwa_flutter/features/courses/data/models/dashboard_stats.dart';

class CourseApiService {
  final DioClient _dioClient = DioClient();

  Future<PageResponse<CourseInfo>> getCourses({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String direction = 'ASC',
  }) async {
    try {
      final response = await _dioClient.get(
        '/courses',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'direction': direction,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CourseInfo.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<CourseInfo> getCourseById(int id) async {
    try {
      final response = await _dioClient.get('/courses/$id');
      return CourseInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PageResponse<CourseInfo>> getCoursesByLevel(
    String level, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        '/courses/level/$level',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CourseInfo.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<CourseInfo>> getAllCourses() async {
    try {
      final response = await _dioClient.get(
        '/courses',
        queryParameters: {
          'page': 0,
          'size': 100,
        },
      );
      final pageResponse = PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CourseInfo.fromJson(json),
      );
      return pageResponse.content;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<DashboardStats> getDashboardStats({int? userId}) async {
    try {
      final path = userId != null 
          ? '/courses/dashboard-stats/$userId'
          : '/courses/dashboard-stats';
      final response = await _dioClient.get(path);
      return DashboardStats.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<CourseInfo> enrollCourse(int courseId, int userId) async {
    try {
      final response = await _dioClient.post('/courses/$courseId/enroll/$userId');
      return CourseInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

