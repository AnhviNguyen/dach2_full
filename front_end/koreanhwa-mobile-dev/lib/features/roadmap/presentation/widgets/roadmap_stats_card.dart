import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class RoadmapStatsCard extends StatelessWidget {
  final int completedDays;
  final int totalQuestions;
  final double progress;

  const RoadmapStatsCard({
    super.key,
    required this.completedDays,
    required this.totalQuestions,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '$completedDays',
                style: const TextStyle(
                  color: AppColors.primaryYellow,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Ngày hoàn thành',
                style: TextStyle(
                  color: AppColors.grayLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '$totalQuestions',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Câu hỏi đã làm',
                style: TextStyle(
                  color: AppColors.grayLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.info,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Tiến độ tổng thể',
                style: TextStyle(
                  color: AppColors.grayLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

