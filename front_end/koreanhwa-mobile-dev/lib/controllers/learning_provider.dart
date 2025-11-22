import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/lesson_model.dart.dart';

class LearningProvider extends ChangeNotifier {
  List<LessonModel> _lessons = [];

  List<LessonModel> get lessons => _lessons;

  void initializeLessons() {
    _lessons = [
      LessonModel(
        id: '1',
        title: 'Bắt đầu học tiếng Hàn trong 5 phút',
        description: 'Những câu xin điều chỉnh cho bạn hay, học ngay bắt nay. Khám phá lộ trình học tốt nhất',
        imageUrl: 'assets/images/penguin_study.png',
      ),
    ];
    notifyListeners();
  }

  void startLesson(String lessonId) {
    // Logic to start lesson
    notifyListeners();
  }
}