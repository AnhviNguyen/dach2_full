import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_result.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class CompetitionResultWinScreen extends StatelessWidget {
  final CompetitionResult? result;

  const CompetitionResultWinScreen({super.key, this.result});

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
              // Trophy Icon
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryYellow,
                      AppColors.primaryYellow.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryYellow.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Chúc mừng!',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn đã giành chiến thắng!',
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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryYellow,
                      AppColors.primaryYellow.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryYellow.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      result!.competitionTitle,
                      style: const TextStyle(
                        color: AppColors.primaryBlack,
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
                    if (result!.prizeAmount != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlack,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Giải thưởng',
                              style: TextStyle(
                                color: AppColors.primaryWhite,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${result!.prizeAmount!.toLocaleString()} VNĐ',
                              style: const TextStyle(
                                color: AppColors.primaryYellow,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          context.push('/competition/prize-claim', extra: result);
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
                          'Nhận giải thưởng',
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
                        context.go('/competition');
                      },
                      child: const Text(
                        'Về trang cuộc thi',
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
        Icon(icon, color: AppColors.primaryBlack, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.primaryBlack.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

extension NumberExtension on int {
  String toLocaleString() {
    final numberStr = toString();
    final reversed = numberStr.split('').reversed.join();
    final chunks = <String>[];
    for (int i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.substring(i, (i + 3 > reversed.length) ? reversed.length : i + 3));
    }
    return chunks.join('.').split('').reversed.join();
  }
}

