import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/models/speak_stat.dart';

class SpeakStatsRow extends StatelessWidget {
  final List<SpeakStat> stats;

  const SpeakStatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: const TextStyle(
                    color: AppColors.grayLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stat.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  stat.subtitle,
                  style: const TextStyle(color: AppColors.grayLight, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

