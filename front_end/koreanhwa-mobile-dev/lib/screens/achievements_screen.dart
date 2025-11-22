import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      _AchievementItem(
        iconLabel: 'M',
        title: 'Hoàn thành Bài học',
        subtitle: 'Bài 1: Giới thiệu bản thân',
        count: 2,
        color: AppColors.success,
        isCompleted: true,
        progress: 1.0,
      ),
      _AchievementItem(
        iconLabel: 'S',
        title: 'Streak 10 ngày',
        subtitle: 'Học liên tục 10 ngày',
        count: 1,
        color: AppColors.primaryYellow,
        isCompleted: true,
        progress: 1.0,
      ),
      _AchievementItem(
        iconLabel: 'T',
        title: 'Tích lũy 1000 từ vựng',
        subtitle: 'Học từ vựng mỗi ngày',
        count: 2,
        color: const Color(0xFF2196F3),
        isCompleted: true,
        progress: 1.0,
      ),
      _AchievementItem(
        iconLabel: 'G',
        title: 'Giải đúng 100 câu',
        subtitle: 'Luyện tập chăm chỉ',
        count: 3,
        color: const Color(0xFF9C27B0),
        isCompleted: false,
        progress: 0.75,
      ),
      _AchievementItem(
        iconLabel: 'P',
        title: 'Đạt điểm cao',
        subtitle: 'Vượt qua bài kiểm tra',
        count: 1,
        color: const Color(0xFFFF5722),
        isCompleted: false,
        progress: 0.5,
      ),
      _AchievementItem(
        iconLabel: 'C',
        title: 'Hoàn thành chương',
        subtitle: 'Chương 1: Ngữ pháp cơ bản',
        count: 2,
        color: const Color(0xFF00BCD4),
        isCompleted: false,
        progress: 0.3,
      ),
    ];

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
            // Timeline with achievements
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline line
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
                // Achievement cards
                Expanded(
                  child: Column(
                    children: achievements.asMap().entries.map((entry) {
                      final index = entry.key;
                      final achievement = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < achievements.length - 1 ? 20 : 0,
                        ),
                        child: _buildAchievementCard(achievement, index),
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

  Widget _buildAchievementCard(_AchievementItem achievement, int index) {
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

class _AchievementItem {
  final String iconLabel;
  final String title;
  final String subtitle;
  final int count;
  final Color color;
  final bool isCompleted;
  final double progress;

  const _AchievementItem({
    required this.iconLabel,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.color,
    required this.isCompleted,
    required this.progress,
  });
}
