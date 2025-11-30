import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_placement_result.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_section.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_day.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoadmapService {
  static RoadmapPlacementResult? _placementResult;
  static int? _userLevel;
  static int? _textbookUnlock;
  
  static const String _keyPlacementResult = 'roadmap_placement_result';
  static const String _keyUserLevel = 'roadmap_user_level';
  static const String _keyTextbookUnlock = 'roadmap_textbook_unlock';

  static bool hasCompletedPlacement() {
    return _placementResult != null;
  }

  static RoadmapPlacementResult? getPlacementResult() {
    return _placementResult;
  }

  static Future<void> savePlacementResult(int level, int score) async {
    _placementResult = RoadmapPlacementResult(
      level: level,
      score: score,
      completedAt: DateTime.now(),
    );
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserLevel, level);
    await prefs.setInt(_keyTextbookUnlock, level > 1 ? level - 1 : 0);
  }
  
  static Future<void> loadPlacementResult() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getInt(_keyUserLevel);
    final unlock = prefs.getInt(_keyTextbookUnlock);
    
    if (level != null) {
      _userLevel = level;
      _textbookUnlock = unlock ?? (level > 1 ? level - 1 : 0);
      _placementResult = RoadmapPlacementResult(
        level: level,
        score: 0, // Score not saved separately
        completedAt: DateTime.now(),
      );
    }
  }
  
  static int? getUserLevel() {
    return _userLevel;
  }
  
  static int? getTextbookUnlock() {
    return _textbookUnlock;
  }
  
  static Future<void> setUserLevel(int level, int textbookUnlock) async {
    _userLevel = level;
    _textbookUnlock = textbookUnlock;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserLevel, level);
    await prefs.setInt(_keyTextbookUnlock, textbookUnlock);
  }
  
  /// Clear placement result to allow retaking the test
  static Future<void> clearPlacementResult() async {
    _placementResult = null;
    _userLevel = null;
    _textbookUnlock = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserLevel);
    await prefs.remove(_keyTextbookUnlock);
    await prefs.remove(_keyPlacementResult);
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

