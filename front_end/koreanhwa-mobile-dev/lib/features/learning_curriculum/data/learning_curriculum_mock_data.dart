import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/vocabulary_item.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/grammar_item.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/exercise_item.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/lesson_tab.dart';
import 'package:flutter/material.dart';

class LearningCurriculumMockData {
  static final Map<String, dynamic> lessonData = {
    'title': 'Bài 1: Chào hỏi cơ bản',
    'level': 'Sơ cấp 1',
    'duration': '45 phút',
    'progress': 60,
  };

  static final List<VocabularyItem> vocabulary = const [
    VocabularyItem(
      korean: '안녕하세요',
      vietnamese: 'Xin chào',
      pronunciation: 'an-nyeong-ha-se-yo',
      example: '안녕하세요, 저는 마이클입니다.',
    ),
    VocabularyItem(
      korean: '감사합니다',
      vietnamese: 'Cảm ơn',
      pronunciation: 'gam-sa-ham-ni-da',
      example: '감사합니다, 선생님.',
    ),
    VocabularyItem(
      korean: '안녕히 가세요',
      vietnamese: 'Tạm biệt',
      pronunciation: 'an-nyeong-hi ga-se-yo',
      example: '안녕히 가세요, 내일 봐요.',
    ),
    VocabularyItem(
      korean: '네',
      vietnamese: 'Vâng',
      pronunciation: 'ne',
      example: '네, 알겠습니다.',
    ),
    VocabularyItem(
      korean: '아니요',
      vietnamese: 'Không',
      pronunciation: 'a-ni-yo',
      example: '아니요, 모르겠습니다.',
    ),
  ];

  static final List<GrammarItem> grammar = const [
    GrammarItem(
      title: 'Cấu trúc chào hỏi',
      explanation: '안녕하세요 được sử dụng để chào hỏi một cách lịch sự',
      examples: [
        '안녕하세요, 저는 [이름]입니다. (Xin chào, tôi là [tên])',
        '안녕하세요, 만나서 반갑습니다. (Xin chào, rất vui được gặp bạn)',
      ],
    ),
  ];

  static final List<ExerciseItem> exercises = const [
    ExerciseItem(
      id: 1,
      type: 'multiple_choice',
      question: 'Cách chào hỏi lịch sự trong tiếng Hàn là gì?',
      options: ['안녕', '안녕하세요', '안녕히 가세요', '감사합니다'],
      correct: 1,
    ),
    ExerciseItem(
      id: 2,
      type: 'fill_blank',
      question: 'Điền từ thích hợp: "안녕하세요, 저는 마이클___입니다."',
      answer: '입니다',
    ),
  ];

  static final List<LessonTab> tabs = const [
    LessonTab(id: 'video', name: 'Video', icon: Icons.video_library),
    LessonTab(id: 'vocabulary', name: 'Từ vựng', icon: Icons.book),
    LessonTab(id: 'listening', name: 'Nghe', icon: Icons.headphones),
    LessonTab(id: 'grammar', name: 'Ngữ pháp', icon: Icons.menu_book),
    LessonTab(id: 'exercise', name: 'Bài tập', icon: Icons.edit),
    LessonTab(id: 'ai-chat', name: 'AI Chat', icon: Icons.chat),
  ];
}

