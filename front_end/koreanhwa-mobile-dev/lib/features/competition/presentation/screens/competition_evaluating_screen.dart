import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/models/competition_model.dart';
import 'package:koreanhwa_flutter/services/competition_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class CompetitionEvaluatingScreen extends StatefulWidget {
  final Competition? competition;

  const CompetitionEvaluatingScreen({super.key, this.competition});

  @override
  State<CompetitionEvaluatingScreen> createState() => _CompetitionEvaluatingScreenState();
}

class _CompetitionEvaluatingScreenState extends State<CompetitionEvaluatingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate evaluation delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.competition != null) {
        CompetitionService.completeEvaluation(widget.competition!.id);
        _checkEvaluationStatus();
      }
    });
  }

  void _checkEvaluationStatus() {
    final result = CompetitionService.getResult(widget.competition?.id ?? 0);
    if (result != null && result.evaluationStatus == 'completed') {
      if (result.isWinner) {
        context.pushReplacement('/competition/result-win', extra: result);
      } else {
        context.pushReplacement('/competition/result-lose', extra: result);
      }
    } else {
      // If still evaluating, check again after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _checkEvaluationStatus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
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
              'Đang đánh giá bài thi của bạn',
              style: TextStyle(
                color: AppColors.primaryWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vui lòng chờ trong giây lát...',
              style: TextStyle(
                color: AppColors.grayLight,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            // Progress Indicator
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.grayLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
              ),
            ),
            const SizedBox(height: 32),
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
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primaryYellow),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Thời gian đánh giá thường mất từ 1-3 ngày',
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
                          'Bạn sẽ nhận được thông báo khi có kết quả',
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
          ],
        ),
      ),
    );
  }
}

