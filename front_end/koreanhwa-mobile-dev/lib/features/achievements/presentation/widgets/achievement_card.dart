import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/achievements/data/models/achievement_item.dart';

class AchievementCard extends StatelessWidget {
  final AchievementItem achievement;
  final int index;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isCompleted
              ? achievement.color
              : AppColors.primaryBlack.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: achievement.isCompleted
            ? [
                BoxShadow(
                  color: achievement.color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: achievement.color,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: achievement.color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    achievement.iconLabel,
                    style: const TextStyle(
                      color: AppColors.primaryWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlack.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (achievement.isCompleted)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: achievement.color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.primaryWhite,
                    size: 20,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: achievement.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: achievement.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    achievement.count.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: achievement.color,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          if (!achievement.isCompleted) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: achievement.progress,
                minHeight: 8,
                backgroundColor: AppColors.primaryBlack.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(achievement.progress * 100).round()}% hoàn thành',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryBlack.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

