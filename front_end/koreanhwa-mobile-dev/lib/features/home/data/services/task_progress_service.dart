import 'package:dio/dio.dart';
import 'package:koreanhwa_flutter/core/config/ai_api_config.dart';
import 'package:koreanhwa_flutter/core/network/ai_dio_client.dart';
import 'package:koreanhwa_flutter/core/network/api_exception.dart';

/// Service để cập nhật task progress trong roadmap (AI backend)
class TaskProgressService {
  final AiDioClient _dioClient = AiDioClient();

  /// Đánh dấu task đã hoàn thành và cập nhật progress
  /// 
  /// [taskType] có thể là:
  /// - textbook_learn: Hoàn thành bài học trong giáo trình
  /// - topik_practice: Hoàn thành đề thi TOPIK
  /// - vocab_flashcard: Hoàn thành học từ vựng bằng flashcard
  /// - vocab_test: Hoàn thành bài test từ vựng
  /// - speak_practice: Hoàn thành luyện phát âm
  /// - textbook_vocab: Hoàn thành phần từ vựng của bài học
  /// - textbook_grammar: Hoàn thành phần ngữ pháp
  /// - textbook_exercise: Hoàn thành bài tập
  /// 
  /// [taskData] là dữ liệu bổ sung (book_id, lesson_id, exam_id, etc.)
  Future<Map<String, dynamic>> completeTask({
    required int userId,
    required String taskType,
    Map<String, dynamic>? taskData,
  }) async {
    try {
      final response = await _dioClient.post(
        AiApiConfig.progressTaskComplete,
        data: {
          'user_id': userId,
          'task_type': taskType,
          'task_data': taskData ?? {},
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Helper methods cho các task types phổ biến
  
  /// Hoàn thành bài học trong giáo trình
  Future<void> completeTextbookLesson({
    required int userId,
    int? bookId,
    int? lessonId,
  }) async {
    await completeTask(
      userId: userId,
      taskType: 'textbook_learn',
      taskData: {
        if (bookId != null) 'book_id': bookId,
        if (lessonId != null) 'lesson_id': lessonId,
      },
    );
  }

  /// Hoàn thành đề thi TOPIK
  Future<void> completeTopikExam({
    required int userId,
    String? examId,
    String? examNumber,
  }) async {
    await completeTask(
      userId: userId,
      taskType: 'topik_practice',
      taskData: {
        if (examId != null) 'exam_id': examId,
        if (examNumber != null) 'exam_number': examNumber,
      },
    );
  }

  /// Hoàn thành học từ vựng bằng flashcard
  Future<void> completeVocabularyFlashcard({
    required int userId,
    int? bookId,
    int? lessonId,
  }) async {
    await completeTask(
      userId: userId,
      taskType: 'vocab_flashcard',
      taskData: {
        if (bookId != null) 'book_id': bookId,
        if (lessonId != null) 'lesson_id': lessonId,
      },
    );
  }

  /// Hoàn thành bài test từ vựng
  Future<void> completeVocabularyTest({
    required int userId,
    int? bookId,
    int? lessonId,
  }) async {
    await completeTask(
      userId: userId,
      taskType: 'vocab_test',
      taskData: {
        if (bookId != null) 'book_id': bookId,
        if (lessonId != null) 'lesson_id': lessonId,
      },
    );
  }

  /// Hoàn thành luyện phát âm
  Future<void> completeSpeakingPractice({
    required int userId,
    String? phrase,
  }) async {
    await completeTask(
      userId: userId,
      taskType: 'speak_practice',
      taskData: {
        if (phrase != null) 'phrase': phrase,
      },
    );
  }

  /// Hoàn thành phần từ vựng của bài học
  Future<void> completeTextbookVocabulary({
    required int userId,
    int? bookId,
    int? lessonId,
  }) async {
    await completeTask(
      userId: userId,
      taskType: 'textbook_vocab',
      taskData: {
        if (bookId != null) 'book_id': bookId,
        if (lessonId != null) 'lesson_id': lessonId,
      },
    );
  }

  /// Hoàn thành phần ngữ pháp
  Future<void> completeTextbookGrammar({
    required int userId,
    int? bookId,
    int? lessonId,
  }) async {
    await completeTask(
      userId: userId,
      taskType: 'textbook_grammar',
      taskData: {
        if (bookId != null) 'book_id': bookId,
        if (lessonId != null) 'lesson_id': lessonId,
      },
    );
  }

  /// Hoàn thành bài tập
  Future<void> completeTextbookExercise({
    required int userId,
    int? bookId,
    int? lessonId,
  }) async {
    await completeTask(
      userId: userId,
      taskType: 'textbook_exercise',
      taskData: {
        if (bookId != null) 'book_id': bookId,
        if (lessonId != null) 'lesson_id': lessonId,
      },
    );
  }
}

