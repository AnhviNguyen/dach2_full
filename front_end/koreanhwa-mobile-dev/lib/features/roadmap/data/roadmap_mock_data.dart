import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_level.dart';

class RoadmapMockData {
  static final List<RoadmapLevel> levels = const [
    RoadmapLevel(id: 'level1', name: 'Cấp độ 1', color: AppColors.success),
    RoadmapLevel(id: 'level2', name: 'Cấp độ 2', color: AppColors.primaryYellow),
    RoadmapLevel(id: 'level3', name: 'Cấp độ 3', color: AppColors.warning),
    RoadmapLevel(id: 'level4', name: 'Cấp độ 4', color: AppColors.error),
  ];
}

