import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/models/page_response.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/lessons/data/models/lesson_response.dart';

class LessonApiService {
  final DioClient _dioClient = DioClient();

  // ============================================================================
  // CURRICULUM LESSONS (Giáo trình)
  // ============================================================================

  /// Lấy tất cả curriculum lessons
  Future<PageResponse<LessonResponse>> getAllCurriculumLessons({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String direction = 'ASC',
  }) async {
    try {
      final response = await _dioClient.get(
        '/curriculum-lessons',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'direction': direction,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LessonResponse.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy curriculum lesson theo ID
  Future<LessonResponse> getCurriculumLessonById(int id) async {
    try {
      final response = await _dioClient.get('/curriculum-lessons/$id');
      return LessonResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy curriculum lessons theo curriculum ID
  Future<PageResponse<LessonResponse>> getCurriculumLessonsByCurriculumId(
    int curriculumId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        '/curriculum-lessons/curriculum/$curriculumId',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LessonResponse.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================================
  // COURSE LESSONS (Khóa học với thầy cô)
  // ============================================================================

  /// Lấy tất cả course lessons
  Future<PageResponse<LessonResponse>> getAllCourseLessons({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String direction = 'ASC',
  }) async {
    try {
      final response = await _dioClient.get(
        '/course-lessons',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'direction': direction,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LessonResponse.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy course lesson theo ID
  Future<LessonResponse> getCourseLessonById(int id) async {
    try {
      final response = await _dioClient.get('/course-lessons/$id');
      return LessonResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Lấy course lessons theo course ID
  Future<PageResponse<LessonResponse>> getCourseLessonsByCourseId(
    int courseId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        '/course-lessons/course/$courseId',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LessonResponse.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================================
  // DEPRECATED METHODS - Giữ lại để tương thích ngược
  // ============================================================================

  /// @deprecated Sử dụng getCurriculumLessonsByCurriculumId thay thế
  @Deprecated('Use getCurriculumLessonsByCurriculumId instead')
  Future<PageResponse<LessonResponse>> getLessonsByTextbookId(
    int curriculumId, {
    int page = 0,
    int size = 10,
  }) async {
    return getCurriculumLessonsByCurriculumId(curriculumId, page: page, size: size);
  }

  /// @deprecated Sử dụng getCurriculumLessonById thay thế
  @Deprecated('Use getCurriculumLessonById instead')
  Future<LessonResponse> getLessonById(int id) async {
    return getCurriculumLessonById(id);
  }
}

