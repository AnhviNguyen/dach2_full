import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/vocabulary_item.dart';

class VocabularyCard extends StatelessWidget {
  final VocabularyItem vocabulary;

  const VocabularyCard({
    super.key,
    required this.vocabulary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  vocabulary.korean,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.volume_up,
                  size: 20,
                  color: AppColors.primaryBlack,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            vocabulary.vietnamese,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              vocabulary.pronunciation,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              vocabulary.example,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primaryBlack.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

