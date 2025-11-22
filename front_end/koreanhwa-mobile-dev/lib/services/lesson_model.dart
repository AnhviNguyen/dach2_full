import 'package:koreanhwa_flutter/models/lesson_model.dart.dart';


class LearningService {
  Future<List<LessonModel>> fetchLessons() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return [
      LessonModel(
        id: '1',
        title: 'Bắt đầu học tiếng Hàn trong 5 phút',
        description: 'Những câu xin điều chỉnh cho bạn hay, học ngay bắt nay. Khám phá lộ trình học tốt nhất',
        imageUrl: 'assets/images/penguin_study.png',
        duration: 5,
      ),
    ];
  }

  Future<void> markLessonComplete(String lessonId) async {
    // Logic to mark lesson as complete
    await Future.delayed(const Duration(milliseconds: 500));
  }
}