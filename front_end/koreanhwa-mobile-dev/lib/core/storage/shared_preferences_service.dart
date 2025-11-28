import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:koreanhwa_flutter/features/auth/data/models/auth_models.dart';

class SharedPreferencesService {
  static const String _keyUser = 'user_data';
  static const String _keyUserId = 'user_id';
  static const String _keyUserLevel = 'user_level';
  static const String _keyUserPoints = 'user_points';
  static const String _keyUserStreak = 'user_streak';
  static const String _keyUserAvatar = 'user_avatar';
  static const String _keyLastStudyDate = 'last_study_date';
  static const String _keyStudyDays = 'study_days';
  static const String _keyTaskProgress = 'task_progress';
  static const String _keyExamDate = 'exam_date'; // Ngày dự thi TOPIK
  static const String _keyTargetScore = 'target_score'; // Điểm mục tiêu
  static const String _keyTargetLevel = 'target_level'; // Level mục tiêu (ví dụ: Level 5)

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // User data
  static Future<void> saveUser(UserModel user) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    await prefs.setInt(_keyUserId, user.id);
    if (user.level != null) await prefs.setString(_keyUserLevel, user.level!);
    if (user.points != null) await prefs.setInt(_keyUserPoints, user.points!);
    if (user.streakDays != null) await prefs.setInt(_keyUserStreak, user.streakDays!);
    if (user.avatar != null) await prefs.setString(_keyUserAvatar, user.avatar!);
  }

  static Future<UserModel?> getUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    final prefs = await _prefs;
    await prefs.remove(_keyUser);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserLevel);
    await prefs.remove(_keyUserPoints);
    await prefs.remove(_keyUserStreak);
    await prefs.remove(_keyUserAvatar);
  }

  // Study tracking
  static Future<void> updateLastStudyDate(DateTime date) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLastStudyDate, date.toIso8601String());
  }

  static Future<DateTime?> getLastStudyDate() async {
    final prefs = await _prefs;
    final dateStr = prefs.getString(_keyLastStudyDate);
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  static Future<void> addStudyDay(DateTime date) async {
    final prefs = await _prefs;
    final studyDays = await getStudyDays();
    final dateKey = '${date.year}-${date.month}-${date.day}';
    if (!studyDays.contains(dateKey)) {
      studyDays.add(dateKey);
      await prefs.setStringList(_keyStudyDays, studyDays.toList());
    }
  }

  static Future<Set<String>> getStudyDays() async {
    final prefs = await _prefs;
    final days = prefs.getStringList(_keyStudyDays) ?? [];
    return days.toSet();
  }

  static Future<bool> hasStudiedToday() async {
    final today = DateTime.now();
    final studyDays = await getStudyDays();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    return studyDays.contains(todayKey);
  }

  // Task progress tracking
  static Future<void> saveTaskProgress(double progress) async {
    final prefs = await _prefs;
    await prefs.setDouble(_keyTaskProgress, progress);
  }

  static Future<double> getTaskProgress() async {
    final prefs = await _prefs;
    return prefs.getDouble(_keyTaskProgress) ?? 0.0;
  }

  static Future<void> clearTaskProgress() async {
    final prefs = await _prefs;
    await prefs.remove(_keyTaskProgress);
  }

  // Exam settings (TOPIK)
  /// Lưu ngày dự thi TOPIK
  static Future<void> saveExamDate(DateTime date) async {
    final prefs = await _prefs;
    await prefs.setString(_keyExamDate, date.toIso8601String());
  }

  /// Lấy ngày dự thi TOPIK
  static Future<DateTime?> getExamDate() async {
    final prefs = await _prefs;
    final dateStr = prefs.getString(_keyExamDate);
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// Lưu điểm mục tiêu
  static Future<void> saveTargetScore(String level, int score) async {
    final prefs = await _prefs;
    await prefs.setString(_keyTargetLevel, level);
    await prefs.setInt(_keyTargetScore, score);
  }

  /// Lấy điểm mục tiêu
  static Future<Map<String, dynamic>?> getTargetScore() async {
    final prefs = await _prefs;
    final level = prefs.getString(_keyTargetLevel);
    final score = prefs.getInt(_keyTargetScore);
    if (level == null && score == null) return null;
    return {
      'level': level ?? 'Level 5',
      'score': score ?? 230,
    };
  }

  /// Xóa cài đặt exam
  static Future<void> clearExamSettings() async {
    final prefs = await _prefs;
    await prefs.remove(_keyExamDate);
    await prefs.remove(_keyTargetScore);
    await prefs.remove(_keyTargetLevel);
  }
}

