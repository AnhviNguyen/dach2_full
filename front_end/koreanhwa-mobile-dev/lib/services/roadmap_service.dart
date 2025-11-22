import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_placement_result.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_section.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_day.dart';

class RoadmapService {
  static RoadmapPlacementResult? _placementResult;

  static bool hasCompletedPlacement() {
    return _placementResult != null;
  }

  static RoadmapPlacementResult? getPlacementResult() {
    return _placementResult;
  }

  static void savePlacementResult(int level, int score) {
    _placementResult = RoadmapPlacementResult(
      level: level,
      score: score,
      completedAt: DateTime.now(),
    );
  }

  static List<RoadmapSection> getRoadmapSections() {
    return [
      RoadmapSection(
        period: 'Ngày 1 - 6',
        title: 'Chọn đáp án đúng',
        target: 'Mục tiêu: 11 điểm',
        icon: 'headphones',
        color: 'yellow',
        days: [
          RoadmapDay(day: 1, type: 'Luyện tập', questions: '15 câu hỏi', status: 'completed', hasTest: false),
          RoadmapDay(day: 2, type: 'Luyện tập', questions: '15 câu hỏi', status: 'available', hasTest: true),
          RoadmapDay(day: 3, type: 'Luyện tập', questions: '15 câu hỏi', status: 'locked', hasTest: false),
          RoadmapDay(day: 4, type: 'Luyện tập', questions: '15 câu hỏi', status: 'locked', hasTest: true),
          RoadmapDay(day: 5, type: 'Luyện tập', questions: '15 câu hỏi', status: 'locked', hasTest: false),
          RoadmapDay(day: 6, type: 'Luyện tập', questions: '15 câu hỏi', status: 'locked', hasTest: true),
        ],
      ),
      RoadmapSection(
        period: 'Ngày 7 - 9',
        title: 'Tìm câu nói tiếp',
        target: 'Mục tiêu: 4 điểm',
        icon: 'users',
        color: 'yellow',
        days: [],
      ),
      RoadmapSection(
        period: 'Ngày 10 - 15',
        title: 'Tìm địa điểm',
        target: 'Mục tiêu: 10 điểm',
        icon: 'map',
        color: 'yellow',
        days: [],
      ),
      RoadmapSection(
        period: 'Ngày 16',
        title: 'Bài thi thử số 1',
        target: '',
        icon: 'award',
        color: 'yellow',
        isTest: true,
        days: [],
      ),
      RoadmapSection(
        period: 'Ngày 17 - 18',
        title: 'Chọn tranh đúng',
        target: 'Mục tiêu: 4 điểm',
        icon: 'image',
        color: 'yellow',
        days: [],
      ),
    ];
  }

  static int getCompletedDays() {
    final sections = getRoadmapSections();
    int count = 0;
    for (var section in sections) {
      for (var day in section.days) {
        if (day.status == 'completed') count++;
      }
    }
    return count;
  }

  static int getTotalQuestions() {
    return 15; // Example
  }

  static double getProgress() {
    return getCompletedDays() / 18.0;
  }
}

