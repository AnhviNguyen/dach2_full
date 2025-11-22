import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/streak_stat.dart';

class StreakSection extends StatelessWidget {
  const StreakSection({super.key});

  @override
  Widget build(BuildContext context) {
    const colorOrange = Color(0xFFF97316);
    const colorPink = Color(0xFFEC4899);
    const colorPurple = Color(0xFF8B5CF6);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Streak học tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StreakStat(
                title: 'Ngày học',
                value: '12',
                color: colorOrange,
                icon: Icons.check_circle,
              ),
              StreakStat(
                title: 'Ngày nghỉ',
                value: '25',
                color: colorPink,
                icon: Icons.event_busy,
              ),
              StreakStat(
                title: 'Chưa học',
                value: '89',
                color: colorPurple,
                icon: Icons.pending,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colorOrange.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colorOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

