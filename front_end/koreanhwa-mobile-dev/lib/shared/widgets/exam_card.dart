import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/models/exam_model.dart';

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback? onTap;
  final bool isCompleted; // Đánh dấu bài thi đã hoàn thành

  const ExamCard({
    super.key,
    required this.exam,
    this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? AppColors.success
                : (isDark ? AppColors.darkDivider : AppColors.primaryBlack.withOpacity(0.1)),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID Badge với checkmark nếu đã hoàn thành
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.primaryYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.primaryYellow,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      exam.id,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? AppColors.success
                            : (theme.textTheme.bodySmall?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack)),
                      ),
                    ),
                  ),
                ),
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).cardColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Expanded(
              child: Text(
                exam.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Tags
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: exam.tags.take(2).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkDivider : AppColors.primaryBlack.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      color: (theme.textTheme.bodySmall?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack)).withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Stats
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: (theme.iconTheme.color ?? (isDark ? Colors.white : AppColors.primaryBlack)).withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  exam.duration,
                  style: TextStyle(
                    fontSize: 11,
                    color: (theme.textTheme.bodySmall?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack)).withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.people,
                  size: 14,
                  color: (theme.iconTheme.color ?? (isDark ? Colors.white : AppColors.primaryBlack)).withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${exam.participants}',
                  style: TextStyle(
                    fontSize: 11,
                    color: (theme.textTheme.bodySmall?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack)).withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              exam.questions,
              style: TextStyle(
                fontSize: 11,
                color: (theme.textTheme.bodySmall?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack)).withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

