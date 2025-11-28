import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/grammar_item.dart';

class GrammarCard extends StatelessWidget {
  final GrammarItem grammar;

  const GrammarCard({
    super.key,
    required this.grammar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              grammar.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            grammar.explanation,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ví dụ:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          ...grammar.examples.map((example) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                example,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryWhite,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}