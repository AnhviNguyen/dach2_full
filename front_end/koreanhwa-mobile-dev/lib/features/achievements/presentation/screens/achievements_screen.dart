import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/achievements/data/achievements_mock_data.dart';
import 'package:koreanhwa_flutter/features/achievements/presentation/widgets/achievement_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementsMockData.achievements;
    final completedCount = achievements.where((a) => a.isCompleted).length;
    final totalProgress = achievements.fold<double>(0, (sum, a) => sum + a.progress) / achievements.length;

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
        ),
        title: const Text(
          'Thành tích',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryYellow,
                    AppColors.primaryYellow.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryYellow.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: AppColors.primaryBlack,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng thành tích',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completedCount/${achievements.length} thành tích đã đạt được',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryBlack.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: totalProgress,
                            minHeight: 8,
                            backgroundColor: AppColors.primaryBlack.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlack),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: List.generate(
                    achievements.length,
                    (index) {
                      final achievement = achievements[index];
                      final isLast = index == achievements.length - 1;
                      return Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: achievement.isCompleted
                                  ? achievement.color
                                  : AppColors.primaryWhite,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: achievement.isCompleted
                                    ? achievement.color
                                    : AppColors.primaryBlack.withOpacity(0.3),
                                width: 3,
                              ),
                              boxShadow: achievement.isCompleted
                                  ? [
                                      BoxShadow(
                                        color: achievement.color.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: achievement.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.primaryWhite,
                                      size: 24,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: AppColors.primaryBlack,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 4,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: achievement.isCompleted
                                      ? [
                                          achievement.color,
                                          achievements[index + 1].isCompleted
                                              ? achievements[index + 1].color
                                              : AppColors.primaryBlack.withOpacity(0.2),
                                        ]
                                      : [
                                          AppColors.primaryBlack.withOpacity(0.2),
                                          AppColors.primaryBlack.withOpacity(0.2),
                                        ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: achievements.asMap().entries.map((entry) {
                      final index = entry.key;
                      final achievement = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < achievements.length - 1 ? 20 : 0,
                        ),
                        child: AchievementCard(
                          achievement: achievement,
                          index: index,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

