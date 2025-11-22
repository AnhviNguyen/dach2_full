import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class RoadmapPlacementScreen extends StatefulWidget {
  const RoadmapPlacementScreen({super.key});

  @override
  State<RoadmapPlacementScreen> createState() => _RoadmapPlacementScreenState();
}

class _RoadmapPlacementScreenState extends State<RoadmapPlacementScreen> {
  @override
  void initState() {
    super.initState();
    // Check if user has already completed placement test
    if (RoadmapService.hasCompletedPlacement()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacement('/roadmap/detail');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mascot
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryYellow,
                        AppColors.primaryYellow.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(75),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryYellow.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🧙‍♂️',
                      style: TextStyle(fontSize: 80),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'TOPIK Learning',
                  style: TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chào mừng bạn đến với lộ trình học TOPIK!',
                  style: TextStyle(
                    color: AppColors.grayLight,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Bài kiểm tra đầu vào',
                        style: TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Để xây dựng lộ trình phù hợp, bạn cần làm bài kiểm tra đầu vào. Bài kiểm tra này chỉ thực hiện 1 lần duy nhất.',
                        style: TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, color: AppColors.primaryYellow, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '8 phút',
                            style: TextStyle(color: AppColors.primaryWhite),
                          ),
                          const SizedBox(width: 24),
                          Icon(Icons.quiz, color: AppColors.primaryYellow, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '8 câu',
                            style: TextStyle(color: AppColors.primaryWhite),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/roadmap/test');
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
                      'Bắt đầu kiểm tra',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

