import 'package:koreanhwa_flutter/models/exam_model.dart';

class ExamService {
  static List<String> get examCategories => [
        'Tất cả',
        'TOPIK I',
        'TOPIK II',
        'KLAT',
        'KBS',
        'FLEX',
        'KLPT',
        'OPIc',
        'S-TOPIK',
        'SNULT',
        'KOSTAT',
        'KICE',
        'KCT',
        'KIIP',
        'KIBS',
        'Korean SAT',
        'Sejong Institute',
        'King Sejong',
        'Hangeul Test',
        'Korean Proficiency',
      ];

  static List<ExamModel> get examData => [
        ExamModel(
          id: 'TK2001',
          title: 'TOPIK II Reading & Listening Test 01',
          duration: '110 phút',
          participants: 4521,
          questions: '3 phần thi | 70 câu hỏi',
          tags: ['TOPIK II', 'Reading', 'Listening'],
        ),
        ExamModel(
          id: 'TK1015',
          title: 'TOPIK I Simulation Test 15',
          duration: '100 phút',
          participants: 2845,
          questions: '2 phần thi | 70 câu hỏi',
          tags: ['TOPIK I', 'Reading', 'Listening'],
        ),
        ExamModel(
          id: 'KL003',
          title: 'KLAT Korean Listening Practice 03',
          duration: '45 phút',
          participants: 1892,
          questions: '4 phần thi | 50 câu hỏi',
          tags: ['KLAT', 'Listening'],
        ),
        ExamModel(
          id: 'TK2W05',
          title: 'TOPIK II Writing Practice Test 05',
          duration: '70 phút',
          participants: 1654,
          questions: '2 phần thi | 4 câu viết',
          tags: ['TOPIK II', 'Writing'],
        ),
        ExamModel(
          id: 'OP78',
          title: 'OPIc Korean Speaking Level 7-8',
          duration: '25 phút',
          participants: 987,
          questions: '3 phần thi | 15 câu nói',
          tags: ['OPIc', 'Speaking'],
        ),
        ExamModel(
          id: 'FX001',
          title: 'FLEX Korean Proficiency Mock Test',
          duration: '120 phút',
          participants: 2156,
          questions: '4 phần thi | 100 câu hỏi',
          tags: ['FLEX', 'Comprehensive'],
        ),
        ExamModel(
          id: 'KBS02',
          title: 'KBS Korean Broadcasting Test 02',
          duration: '90 phút',
          participants: 743,
          questions: '3 phần thi | 60 câu hỏi',
          tags: ['KBS', 'Broadcasting'],
        ),
        ExamModel(
          id: 'TK1G12',
          title: 'TOPIK I Grammar & Vocabulary 12',
          duration: '40 phút',
          participants: 3421,
          questions: '1 phần thi | 30 câu hỏi',
          tags: ['TOPIK I', 'Grammar'],
        ),
        ExamModel(
          id: 'STK01',
          title: 'S-TOPIK Speaking Test Advanced',
          duration: '30 phút',
          participants: 1265,
          questions: '2 phần thi | 6 câu nói',
          tags: ['S-TOPIK', 'Speaking'],
        ),
        ExamModel(
          id: 'KLP4',
          title: 'KLPT Korean Language Test Level 4',
          duration: '80 phút',
          participants: 2089,
          questions: '3 phần thi | 75 câu hỏi',
          tags: ['KLPT', 'Level 4'],
        ),
        ExamModel(
          id: 'SJ001',
          title: 'Sejong Institute Placement Test',
          duration: '60 phút',
          participants: 1543,
          questions: '4 phần thi | 50 câu hỏi',
          tags: ['Sejong Institute', 'Placement'],
        ),
        ExamModel(
          id: 'KI03',
          title: 'KIIP Korean Integration Program L3',
          duration: '75 phút',
          participants: 867,
          questions: '3 phần thi | 45 câu hỏi',
          tags: ['KIIP', 'Integration'],
        ),
        ExamModel(
          id: 'HG001',
          title: 'Hangeul Proficiency Test Beginner',
          duration: '50 phút',
          participants: 2734,
          questions: '2 phần thi | 40 câu hỏi',
          tags: ['Hangeul Test', 'Beginner'],
        ),
      ];

  static List<ExamModel> filterExams({
    String? category,
    String? searchQuery,
  }) {
    var filtered = examData;

    if (category != null && category != 'all' && category != 'Tất cả') {
      filtered = filtered
          .where((exam) => exam.tags.any((tag) => tag.contains(category)))
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered
          .where((exam) =>
              exam.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }
}

