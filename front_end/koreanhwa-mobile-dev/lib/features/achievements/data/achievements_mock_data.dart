import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/achievements/data/models/achievement_item.dart';

class AchievementsMockData {
  static final List<AchievementItem> achievements = [
    AchievementItem(
      iconLabel: 'M',
      title: 'Hoàn thành Bài học',
      subtitle: 'Bài 1: Giới thiệu bản thân',
      count: 2,
      color: AppColors.success,
      isCompleted: true,
      progress: 1.0,
    ),
    AchievementItem(
      iconLabel: 'S',
      title: 'Streak 10 ngày',
      subtitle: 'Học liên tục 10 ngày',
      count: 1,
      color: AppColors.primaryYellow,
      isCompleted: true,
      progress: 1.0,
    ),
    AchievementItem(
      iconLabel: 'T',
      title: 'Tích lũy 1000 từ vựng',
      subtitle: 'Học từ vựng mỗi ngày',
      count: 2,
      color: const Color(0xFF2196F3),
      isCompleted: true,
      progress: 1.0,
    ),
    AchievementItem(
      iconLabel: 'G',
      title: 'Giải đúng 100 câu',
      subtitle: 'Luyện tập chăm chỉ',
      count: 3,
      color: const Color(0xFF9C27B0),
      isCompleted: false,
      progress: 0.75,
    ),
    AchievementItem(
      iconLabel: 'P',
      title: 'Đạt điểm cao',
      subtitle: 'Vượt qua bài kiểm tra',
      count: 1,
      color: const Color(0xFFFF5722),
      isCompleted: false,
      progress: 0.5,
    ),
    AchievementItem(
      iconLabel: 'C',
      title: 'Hoàn thành chương',
      subtitle: 'Chương 1: Ngữ pháp cơ bản',
      count: 2,
      color: const Color(0xFF00BCD4),
      isCompleted: false,
      progress: 0.3,
    ),
  ];
}

