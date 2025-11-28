import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/lesson_tab.dart';

class LessonTabButton extends StatelessWidget {
  final LessonTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const LessonTabButton({
    super.key,
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryYellow
                  : AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBlack,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  tab.icon,
                  size: 18,
                  color: AppColors.primaryBlack,
                ),
                const SizedBox(width: 6),
                Text(
                  tab.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}