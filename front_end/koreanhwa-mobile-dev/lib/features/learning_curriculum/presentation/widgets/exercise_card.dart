import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/exercise_item.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseItem exercise;
  final int index;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlack,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Câu ${index + 1}: ${exercise.question}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (exercise.type == 'multiple_choice' && exercise.options != null) ...[
            ...exercise.options!.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio(
                      value: option,
                      groupValue: null,
                      onChanged: (val) {},
                      activeColor: AppColors.primaryYellow,
                    ),
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ] else if (exercise.type == 'fill_blank') ...[
            TextField(
              decoration: InputDecoration(
                hintText: 'Nhập đáp án...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlack,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryYellow,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

