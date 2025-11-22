import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_result.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class CompetitionPrizePendingScreen extends StatelessWidget {
  final CompetitionResult? result;

  const CompetitionPrizePendingScreen({super.key, this.result});

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Icon(
                      Icons.hourglass_empty,
                      size: 120,
                      color: AppColors.primaryYellow,
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              const Text(
                'Đang chờ xét duyệt',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thông tin nhận giải của bạn đã được gửi',
                style: TextStyle(
                  color: AppColors.grayLight,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              // Info Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    if (result!.prizeAmount != null) ...[
                      Text(
                        '${result!.prizeAmount!.toLocaleString()} VNĐ',
                        style: const TextStyle(
                          color: AppColors.primaryYellow,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Icon(Icons.access_time, color: AppColors.primaryYellow),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Thời gian xét duyệt: 1-3 ngày làm việc',
                            style: TextStyle(
                              color: AppColors.primaryWhite,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.notifications, color: AppColors.primaryYellow),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Bạn sẽ nhận được thông báo khi được duyệt',
                            style: TextStyle(
                              color: AppColors.primaryWhite,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/home');
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
                          'Về trang chủ',
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
                        'Xem cuộc thi khác',
                        style: TextStyle(
                          color: AppColors.primaryYellow,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

