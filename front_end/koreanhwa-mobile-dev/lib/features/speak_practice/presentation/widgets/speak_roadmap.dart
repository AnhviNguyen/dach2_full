import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/models/roadmap_step.dart';

class SpeakRoadmap extends StatelessWidget {
  final List<RoadmapStep> steps;

  const SpeakRoadmap({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryYellow.withOpacity(0.25),
                  child: Text(step.emoji),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 3,
                    height: 36,
                    color: AppColors.primaryYellow,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.description,
                      style: const TextStyle(color: AppColors.grayLight),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

