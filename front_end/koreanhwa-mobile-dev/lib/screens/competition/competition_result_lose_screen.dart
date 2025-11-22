import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/models/competition_model.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class CompetitionResultLoseScreen extends StatelessWidget {
  final CompetitionResult? result;

  const CompetitionResultLoseScreen({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy kết quả')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Icon
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grayLight.withOpacity(0.2),
                  border: Border.all(
                    color: AppColors.grayLight,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.sentiment_dissatisfied,
                  size: 80,
                  color: AppColors.grayLight,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Cảm ơn bạn đã tham gia!',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tiếp tục cố gắng nhé!',
                style: TextStyle(
                  color: AppColors.grayLight,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 48),
              // Result Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.grayLight.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      result!.competitionTitle,
                      style: const TextStyle(
                        color: AppColors.primaryWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Điểm số',
                          '${result!.score}%',
                          Icons.star,
                        ),
                        _buildStatItem(
                          'Xếp hạng',
                          '#${result!.rank}',
                          Icons.emoji_events,
                        ),
                        _buildStatItem(
                          'Đúng',
                          '${result!.correctAnswers}/${result!.totalQuestions}',
                          Icons.check_circle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.primaryYellow,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Lời khuyên',
                            style: TextStyle(
                              color: AppColors.primaryYellow,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy tiếp tục luyện tập để cải thiện kỹ năng của bạn. Thành công đến từ sự kiên trì!',
                            style: TextStyle(
                              color: AppColors.primaryWhite,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/competition');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryBlack,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Xem cuộc thi khác',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      child: const Text(
                        'Về trang chủ',
                        style: TextStyle(
                          color: AppColors.primaryYellow,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryYellow, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.grayLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

