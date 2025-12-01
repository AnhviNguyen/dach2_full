import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_section.dart';

class RoadmapTimelineSection extends StatelessWidget {
  final RoadmapSection section;
  final int index;
  final int total;

  const RoadmapTimelineSection({
    super.key,
    required this.section,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = index == total - 1;
    final color = _getColorFromString(section.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    section.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 100,
                  color: AppColors.primaryYellow.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.period,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primaryBlack),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mục tiêu: ${section.target}',
                    style: TextStyle(
                      color: AppColors.grayLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...section.days.map((day) => _buildDayItem(day, context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(day, BuildContext context) {
    final statusColor = _getStatusColor(day.status);
    final isCompleted = day.status == 'completed';
    final isAvailable = day.status == 'available';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: AppColors.success, size: 18)
                  : isAvailable
                      ? const Icon(Icons.play_arrow, color: AppColors.primaryYellow, size: 18)
                      : const Icon(Icons.lock, color: AppColors.grayLight, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ngày ${day.day}: ${day.type}',
                  style: TextStyle(
                    color: isAvailable || isCompleted
                        ? AppColors.primaryWhite
                        : AppColors.grayLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  day.questions,
                  style: TextStyle(
                    color: AppColors.grayLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isAvailable && day.hasTest)
            IconButton(
              onPressed: () {
                context.push('/roadmap/test', extra: {'day': day.day});
              },
              icon: const Icon(
                Icons.arrow_forward,
                color: AppColors.primaryYellow,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.primaryYellow;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'available':
        return AppColors.primaryYellow;
      case 'locked':
        return AppColors.grayLight;
      default:
        return AppColors.grayLight;
    }
  }
}

