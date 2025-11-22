import 'package:koreanhwa_flutter/models/exam_model.dart';
import 'package:koreanhwa_flutter/services/exam_service.dart';

// Exam provider for state management
// Can be extended with Riverpod/Provider if needed
class ExamProvider {
  List<ExamModel> _exams = ExamService.examData;
  String? _currentCategory;
  String? _currentSearchQuery;

  List<ExamModel> get exams => _exams;
  String? get currentCategory => _currentCategory;
  String? get currentSearchQuery => _currentSearchQuery;

  void filterExams({String? category, String? searchQuery}) {
    _currentCategory = category;
    _currentSearchQuery = searchQuery;
    _exams = ExamService.filterExams(
      category: category,
      searchQuery: searchQuery,
    );
  }

  void reset() {
    _currentCategory = null;
    _currentSearchQuery = null;
    _exams = ExamService.examData;
  }
}

