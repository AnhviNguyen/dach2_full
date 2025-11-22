import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/courses/data/models/course_info.dart';
import 'package:koreanhwa_flutter/features/courses/data/models/dashboard_stats.dart';

class CoursesMockData {
  static const DashboardStats dashboardStats = DashboardStats(
    totalCourses: 80,
    completedCourses: 0,
    totalVideos: 2572,
    watchedVideos: 82,
    totalExams: 36,
    completedExams: 18,
    totalWatchTime: '737:23:52',
    completedWatchTime: '56:26:54',
    lastAccess: '2025-09-13 19:13:56',
    endDate: '4762-07-11',
  );

  static final List<CourseInfo> mockCourses = [
    CourseInfo(
      id: 1,
      title: '[Gonggatm] Tiếng Hàn Sơ Cấp 2 (100 Bài Giảng)',
      instructor: 'Giảng viên A',
      level: 'Sơ Cấp',
      rating: 4.5,
      students: 1200,
      lessons: 100,
      duration: '2025-08-22 ~ 2026-03-20',
      price: '1,000,000 VNĐ',
      progress: 0.04,
      isEnrolled: true,
      accentColor: AppColors.primaryYellow,
    ),
    CourseInfo(
      id: 2,
      title: '[-30%] Tiếng Hàn Sơ Cấp 1 (100 Bài Giảng) - OFF',
      instructor: 'Giảng viên B',
      level: 'Mới',
      rating: 4.8,
      students: 800,
      lessons: 100,
      duration: '2025-06-25 ~ 2030-12-16',
      price: '700,000 VNĐ',
      progress: 0.0,
      isEnrolled: false,
      accentColor: Colors.blue,
    ),
  ];
}

