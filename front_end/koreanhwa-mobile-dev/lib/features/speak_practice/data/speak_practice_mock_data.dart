import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/models/speak_stat.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/models/speak_mission.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/models/roadmap_step.dart';

class SpeakPracticeMockData {
  static final List<SpeakStat> stats = const [
    SpeakStat(
      label: 'Thời lượng',
      value: '24 phút',
      subtitle: 'Hôm nay',
    ),
    SpeakStat(
      label: 'Chuỗi ngày',
      value: '7 ngày',
      subtitle: 'Không bỏ lỡ',
    ),
    SpeakStat(
      label: 'Điểm nói',
      value: '86/100',
      subtitle: 'Tăng 8%',
    ),
  ];

  static final List<SpeakMission> missions = const [
    SpeakMission(
      title: 'Phát âm 10 câu',
      subtitle: 'Còn 3 câu nữa để hoàn thành mục tiêu',
      icon: Icons.graphic_eq,
      color: AppColors.primaryYellow,
    ),
    SpeakMission(
      title: 'Hội thoại 5 phút',
      subtitle: 'Thực hành với chủ đề tự chọn',
      icon: Icons.chat_bubble_outline,
      color: AppColors.blackLight,
    ),
    SpeakMission(
      title: 'Ôn lại lỗi sai',
      subtitle: 'Xem lại 4 âm chưa chính xác hôm qua',
      icon: Icons.refresh,
      color: AppColors.warning,
    ),
  ];

  static final List<RoadmapStep> roadmapSteps = const [
    RoadmapStep(
      title: 'Chuẩn bị khẩu hình',
      description: 'Xem demo và mẹo đặt lưỡi/môi',
      emoji: '🎯',
    ),
    RoadmapStep(
      title: 'Luyện phát âm',
      description: 'Chấm điểm ngay lập tức với AI',
      emoji: '🎙️',
    ),
    RoadmapStep(
      title: 'Hội thoại ngắn',
      description: 'Ứng dụng âm vừa học trong hội thoại',
      emoji: '💬',
    ),
    RoadmapStep(
      title: 'Đánh giá & ghi chú',
      description: 'Ghi nhớ lỗi và đặt mục tiêu mới',
      emoji: '📝',
    ),
  ];
}

