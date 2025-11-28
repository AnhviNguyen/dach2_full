import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExamResult {
  final String examId;
  final String examTitle;
  final Map<int, String> answers;
  final List<Map<String, dynamic>> questions;
  final int timeSpent; // Thời gian đã làm bài (giây)
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final double accuracy;
  final DateTime completedAt;

  ExamResult({
    required this.examId,
    required this.examTitle,
    required this.answers,
    required this.questions,
    required this.timeSpent,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.accuracy,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'examId': examId,
        'examTitle': examTitle,
        'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
        'questions': questions,
        'timeSpent': timeSpent,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'skippedCount': skippedCount,
        'accuracy': accuracy,
        'completedAt': completedAt.toIso8601String(),
      };

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      examId: json['examId'] as String,
      examTitle: json['examTitle'] as String,
      answers: (json['answers'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(int.parse(k), v as String)),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      timeSpent: json['timeSpent'] as int,
      correctCount: json['correctCount'] as int,
      wrongCount: json['wrongCount'] as int,
      skippedCount: json['skippedCount'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}

class ExamResultService {
  static const String _keyExamResults = 'exam_results';
  static const String _keyCompletedExams = 'completed_exams';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Lưu kết quả bài thi
  static Future<void> saveExamResult(ExamResult result) async {
    final prefs = await _prefs;
    
    // Lấy danh sách kết quả hiện tại
    final results = await getExamResults();
    
    // Thêm kết quả mới vào đầu danh sách
    results.insert(0, result);
    
    // Lưu lại danh sách (giới hạn 100 kết quả gần nhất)
    final limitedResults = results.take(100).toList();
    final resultsJson = limitedResults.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyExamResults, resultsJson);
    
    // Lưu danh sách examId đã hoàn thành
    final completedExams = await getCompletedExamIds();
    if (!completedExams.contains(result.examId)) {
      completedExams.add(result.examId);
      await prefs.setStringList(_keyCompletedExams, completedExams.toList());
    }
  }

  /// Lấy tất cả kết quả bài thi
  static Future<List<ExamResult>> getExamResults() async {
    final prefs = await _prefs;
    final resultsJson = prefs.getStringList(_keyExamResults) ?? [];
    
    return resultsJson.map((jsonStr) {
      try {
        return ExamResult.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        return null;
      }
    }).whereType<ExamResult>().toList();
  }

  /// Lấy kết quả theo examId
  static Future<List<ExamResult>> getExamResultsByExamId(String examId) async {
    final results = await getExamResults();
    return results.where((r) => r.examId == examId).toList();
  }

  /// Lấy kết quả gần nhất của một exam
  static Future<ExamResult?> getLatestResultByExamId(String examId) async {
    final results = await getExamResultsByExamId(examId);
    if (results.isEmpty) return null;
    return results.first; // Đã được sắp xếp từ mới đến cũ
  }

  /// Kiểm tra exam đã được hoàn thành chưa
  static Future<bool> isExamCompleted(String examId) async {
    final completedExams = await getCompletedExamIds();
    return completedExams.contains(examId);
  }

  /// Lấy danh sách examId đã hoàn thành
  static Future<Set<String>> getCompletedExamIds() async {
    final prefs = await _prefs;
    final ids = prefs.getStringList(_keyCompletedExams) ?? [];
    return ids.toSet();
  }

  /// Xóa kết quả bài thi
  static Future<void> deleteExamResult(String examId, DateTime completedAt) async {
    final prefs = await _prefs;
    final results = await getExamResults();
    
    // Xóa kết quả có examId và completedAt khớp
    results.removeWhere((r) => 
        r.examId == examId && r.completedAt == completedAt);
    
    // Lưu lại danh sách
    final resultsJson = results.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyExamResults, resultsJson);
    
    // Kiểm tra nếu không còn kết quả nào cho examId này thì xóa khỏi completedExams
    final remainingResults = results.where((r) => r.examId == examId).toList();
    if (remainingResults.isEmpty) {
      final completedExams = await getCompletedExamIds();
      completedExams.remove(examId);
      await prefs.setStringList(_keyCompletedExams, completedExams.toList());
    }
  }

  /// Xóa tất cả kết quả
  static Future<void> clearAllResults() async {
    final prefs = await _prefs;
    await prefs.remove(_keyExamResults);
    await prefs.remove(_keyCompletedExams);
  }
}

