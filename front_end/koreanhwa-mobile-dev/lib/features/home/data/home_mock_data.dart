import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/home/data/models/task_item.dart';
import 'package:koreanhwa_flutter/features/home/data/models/stat_chip_data.dart';
import 'package:koreanhwa_flutter/features/home/data/models/lesson_card_data.dart';
import 'package:koreanhwa_flutter/features/home/data/models/course_card_data.dart';
import 'package:koreanhwa_flutter/features/home/data/models/recent_achievement.dart';
import 'package:koreanhwa_flutter/features/home/data/models/ranking_entry.dart';
import 'package:koreanhwa_flutter/features/home/data/models/skill_progress.dart';
import 'package:koreanhwa_flutter/features/home/data/models/menu_item.dart';
import 'package:koreanhwa_flutter/features/home/data/models/day_tab.dart';

// Định nghĩa màu sắc
const Color colorPurple = Color(0xFF8B5CF6);
const Color colorBlue = Color(0xFF3B82F6);
const Color colorPink = Color(0xFFEC4899);
const Color colorOrange = Color(0xFFF97316);
const Color colorGreen = Color(0xFF10B981);
const Color colorRed = Color(0xFFEF4444);
const Color colorCyan = Color(0xFF06B6D4);
const Color colorIndigo = Color(0xFF6366F1);

class HomeMockData {
  static final List<MenuItem> menuItems = const [
    MenuItem(icon: Icons.article_outlined, label: 'Blog', color: colorPurple),
    MenuItem(icon: Icons.emoji_events_outlined, label: 'Cuộc thi', color: colorOrange),
    MenuItem(icon: Icons.quiz_outlined, label: 'Luyện thi topik', color: colorBlue),
    MenuItem(icon: Icons.book_outlined, label: 'Từ vựng của tôi', color: colorGreen),
    MenuItem(icon: Icons.menu_book_outlined, label: 'Giáo trình', color: colorPink),
    MenuItem(icon: Icons.school_outlined, label: 'Khóa học', color: colorCyan),
    MenuItem(icon: Icons.map_outlined, label: 'Roadmap', color: colorIndigo),
    MenuItem(icon: Icons.assignment_outlined, label: 'Nhiệm vụ', color: AppColors.primaryYellow),
    MenuItem(icon: Icons.mic_outlined, label: 'Luyện nói', color: colorRed),
    MenuItem(icon: Icons.folder_outlined, label: 'Tài liệu', color: colorPurple),
    MenuItem(icon: Icons.settings_outlined, label: 'Cài đặt', color: AppColors.primaryBlack),
  ];

  static final List<TaskItem> dailyTasks = const [
    TaskItem(
      title: 'Học từ vựng',
      icon: Icons.book_outlined,
      color: Color(0xFFFFFBEB),
      progressColor: AppColors.primaryYellow,
      progressPercent: 0.7,
    ),
    TaskItem(
      title: 'Học ngữ pháp',
      icon: Icons.translate,
      color: Color(0xFFF5F5F5),
      progressColor: AppColors.primaryBlack,
      progressPercent: 0.52,
    ),
    TaskItem(
      title: 'Luyện đề',
      icon: Icons.menu_book_outlined,
      color: Color(0xFFFFFBEB),
      progressColor: colorOrange,
      progressPercent: 0.87,
    ),
  ];

  static final List<LessonCardData> lessonCards = const [
    LessonCardData(
      title: 'Tiếng Hàn Sơ cấp 1',
      date: '12/11/2025',
      tag: 'MAR 05',
      accentColor: AppColors.primaryYellow,
      backgroundColor: Color(0xFFFFFBEB),
    ),
    LessonCardData(
      title: 'Tiếng Hàn sơ cấp 2',
      date: '13/11/2025',
      tag: 'MAR 05',
      accentColor: colorOrange,
      backgroundColor: Color(0xFFFFEDD5),
    ),
    LessonCardData(
      title: 'Tiếng Hàn trung cấp 1',
      date: '14/11/2025',
      tag: 'MAR 05',
      accentColor: AppColors.primaryBlack,
      backgroundColor: Color(0xFFF5F5F5),
    ),
  ];

  static final List<CourseCardData> courseCards = const [
    CourseCardData(
      title: 'Khóa học giao tiếp cơ bản',
      progress: 0.65,
      lessons: 24,
      completed: 16,
      accentColor: AppColors.primaryYellow,
    ),
    CourseCardData(
      title: 'Khóa học luyện thi TOPIK I',
      progress: 0.40,
      lessons: 30,
      completed: 12,
      accentColor: colorOrange,
    ),
    CourseCardData(
      title: 'Khóa học từ vựng nâng cao',
      progress: 0.80,
      lessons: 20,
      completed: 16,
      accentColor: colorPurple,
    ),
  ];

  static final List<StatChipData> statChips = const [
    StatChipData(
      title: 'Cấp độ hiện tại',
      value: 'Trung cấp',
      color: AppColors.primaryYellow,
      icon: Icons.school,
    ),
    StatChipData(
      title: 'Tiến độ học',
      value: '30%',
      color: colorOrange,
      icon: Icons.trending_up,
    ),
    StatChipData(
      title: 'Streak học tập',
      value: '12 ngày',
      color: AppColors.primaryBlack,
      icon: Icons.local_fire_department,
    ),
  ];

  static final List<RecentAchievement> recentAchievements = const [
    RecentAchievement(
      iconLabel: '🎯',
      title: 'Hoàn thành Bài học',
      subtitle: 'Bài 1: Giới thiệu bản thân',
      count: 2,
      color: AppColors.primaryYellow,
    ),
    RecentAchievement(
      iconLabel: '🔥',
      title: 'Streak 10 ngày',
      subtitle: 'Học liên tục 10 ngày',
      count: 1,
      color: colorOrange,
    ),
    RecentAchievement(
      iconLabel: '📚',
      title: 'Tích lũy 1000 từ vựng',
      subtitle: 'Học từ vựng mỗi ngày',
      count: 2,
      color: colorGreen,
    ),
  ];

  static final List<RankingEntry> rankingEntries = const [
    RankingEntry(
      position: 1,
      name: 'Thành Tô',
      points: 2320,
      days: 10,
      color: AppColors.primaryYellow,
    ),
    RankingEntry(
      position: 2,
      name: 'Linh Kế',
      points: 2100,
      days: 8,
      color: Color(0xFFE5E7EB),
    ),
    RankingEntry(
      position: 3,
      name: 'Trang Tô C',
      points: 2000,
      days: 7,
      color: Color(0xFFFFEDD5),
    ),
  ];

  static final List<SkillProgress> skills = const [
    SkillProgress(label: 'Nghe', percent: 0.75, color: AppColors.primaryYellow),
    SkillProgress(label: 'Nói', percent: 0.6, color: colorOrange),
    SkillProgress(label: 'Đọc', percent: 0.85, color: colorGreen),
    SkillProgress(label: 'Viết', percent: 0.45, color: colorPurple),
  ];

  static final List<DayTab> weekDays = [
    DayTab(label: 'T2', isStudied: true, color: AppColors.primaryYellow),
    DayTab(label: 'T3', isStudied: true, color: AppColors.primaryYellow),
    DayTab(label: 'T4', isStudied: false, color: AppColors.primaryBlack),
    DayTab(label: 'T5', isStudied: false, color: AppColors.primaryBlack),
    DayTab(label: 'T6', isStudied: false, color: AppColors.primaryBlack),
    DayTab(label: 'T7', isStudied: false, color: AppColors.primaryBlack),
    DayTab(label: 'CN', isStudied: false, color: AppColors.primaryBlack),
  ];
}

