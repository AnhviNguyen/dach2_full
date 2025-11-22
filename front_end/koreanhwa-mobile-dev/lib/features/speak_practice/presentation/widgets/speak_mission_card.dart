import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/models/speak_mission.dart';

class SpeakMissionCard extends StatelessWidget {
  final SpeakMission mission;

  const SpeakMissionCard({
    super.key,
    required this.mission,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mission.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(mission.icon, color: mission.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mission.subtitle,
                  style: const TextStyle(color: AppColors.grayLight),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grayLight),
        ],
      ),
    );
  }
}

