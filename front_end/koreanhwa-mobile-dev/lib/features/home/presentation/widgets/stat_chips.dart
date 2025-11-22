import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/home/data/models/stat_chip_data.dart';

class StatChips extends StatelessWidget {
  final List<StatChipData> statChips;

  const StatChips({super.key, required this.statChips});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: statChips.map((chip) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: chip.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: chip.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(chip.icon, color: chip.color, size: 24),
                const SizedBox(height: 8),
                Text(
                  chip.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: chip.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  chip.title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

