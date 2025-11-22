import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class CoachCard extends StatelessWidget {
  const CoachCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryYellow,
            child: Text('👩‍🏫', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Cô Mi Na · Chuyên gia phát âm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryBlack,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tùy chỉnh giáo án phù hợp với tốc độ học, phản hồi 100% bằng tiếng Việt.',
                  style: TextStyle(color: AppColors.grayLight),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grayLight),
        ],
      ),
    );
  }
}

