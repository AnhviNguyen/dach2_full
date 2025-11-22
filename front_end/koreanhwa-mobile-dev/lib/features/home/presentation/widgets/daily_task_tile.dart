import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/home/data/models/task_item.dart';

class DailyTaskTile extends StatelessWidget {
  final TaskItem task;

  const DailyTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.progressColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: task.progressColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: task.progressColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.progressColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(task.icon, color: task.progressColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: task.progressColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: task.progressPercent,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: task.progressColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(task.progressPercent * 100).round()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: task.progressColor,
            ),
          ),
        ],
      ),
    );
  }
}

