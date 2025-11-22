import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class LessonButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCompleted;
  final VoidCallback onTap;

  const LessonButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.primaryYellow
              : AppColors.primaryBlack.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColors.primaryBlack
                : AppColors.primaryBlack.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleted)
              const Icon(
                Icons.check,
                size: 16,
                color: AppColors.primaryBlack,
              )
            else
              Icon(
                icon,
                size: 16,
                color: AppColors.primaryBlack.withOpacity(0.7),
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? AppColors.primaryBlack
                    : AppColors.primaryBlack.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

