import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/models/page_response.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';
import 'package:koreanhwa_flutter/core/network/dio_client.dart';
import 'package:koreanhwa_flutter/features/blog/data/models/blog_post.dart';
import 'package:koreanhwa_flutter/features/blog/data/models/blog_comment.dart';

class BlogApiService {
  final DioClient _dioClient = DioClient();

  Future<PageResponse<BlogPost>> getPosts({
    int page = 0,
    int size = 10,
    String sortBy = 'createdAt',
    String direction = 'DESC',
    int? currentUserId,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'direction': direction,
      };
      if (currentUserId != null) {
        queryParams['currentUserId'] = currentUserId;
      }

      final response = await _dioClient.get(
        '/blog/posts',
        queryParameters: queryParams,
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => BlogPost.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BlogPost> getPostById(int id, {int? currentUserId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (currentUserId != null) {
        queryParams['currentUserId'] = currentUserId;
      }

      final response = await _dioClient.get(
        '/blog/posts/$id',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return BlogPost.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BlogPost> createPost(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/blog/posts', data: data);
      return BlogPost.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BlogPost> updatePost(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('/blog/posts/$id', data: data);
      return BlogPost.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deletePost(int id) async {
    try {
      await _dioClient.delete('/blog/posts/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PageResponse<BlogPost>> getPostsByAuthor(
    int authorId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        '/blog/posts/author/$authorId',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => BlogPost.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BlogPost> toggleLike(int postId, int userId) async {
    try {
      final response = await _dioClient.post('/blog/posts/$postId/like/$userId');
      return BlogPost.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<BlogComment>> getComments(int postId, {int? currentUserId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (currentUserId != null) {
        queryParams['currentUserId'] = currentUserId;
      }
      final response = await _dioClient.get(
        '/blog/posts/$postId/comments',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return (response.data as List<dynamic>)
          .map((item) => BlogComment.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BlogComment> createComment(int postId, int userId, String content) async {
    try {
      final response = await _dioClient.post(
        '/blog/posts/$postId/comments',
        data: {
          'userId': userId,
          'content': content,
        },
      );
      return BlogComment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> incrementView(int postId) async {
    try {
      await _dioClient.post('/blog/posts/$postId/view');
    } on DioException catch (e) {
      // Silently fail - view increment is not critical
    }
  }
}

