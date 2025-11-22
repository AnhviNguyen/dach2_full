import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_section.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/roadmap_mock_data.dart';
import 'package:koreanhwa_flutter/features/roadmap/presentation/widgets/roadmap_timeline_section.dart';
import 'package:koreanhwa_flutter/features/roadmap/presentation/widgets/roadmap_stats_card.dart';

class RoadmapDetailScreen extends StatefulWidget {
  const RoadmapDetailScreen({super.key});

  @override
  State<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends State<RoadmapDetailScreen> {
  String _selectedLevel = 'level1';

  @override
  Widget build(BuildContext context) {
    final sections = RoadmapService.getRoadmapSections();
    final completedDays = RoadmapService.getCompletedDays();
    final totalQuestions = RoadmapService.getTotalQuestions();
    final progress = RoadmapService.getProgress();

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryBlack,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'TOPIK Learning',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlack,
                      AppColors.primaryBlack.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.timeline,
                    size: 80,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryWhite),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tiến độ: $completedDays/18 ngày',
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryYellow,
                          AppColors.primaryYellow.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text('🧙‍♂️', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'TOPIK Master',
                            style: TextStyle(
                              color: AppColors.primaryYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hướng dẫn viên AI',
                          style: TextStyle(
                            color: AppColors.primaryBlack,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Cấu trúc Lộ trình',
                    style: TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lộ trình được chia nhỏ thành từng dạng bài đang có trong đề thi TOPIK hiện hành.',
                    style: TextStyle(
                      color: AppColors.grayLight,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mỗi dạng bài sẽ có 1 mục tiêu điểm được các giáo viên đặt ra. Để đạt điểm đó TOPIK, các bạn được khuyến rằng nên đạt các điểm mục tiêu này.',
                    style: TextStyle(
                      color: AppColors.grayLight,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                          '📊 Hãy cùng nhau chinh phục TOPIK nhé!',
                          style: TextStyle(
                            color: AppColors.primaryYellow,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '8 phút',
                                  style: TextStyle(
                                    color: AppColors.primaryYellow,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Thời gian',
                                  style: TextStyle(
                                    color: AppColors.grayLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '8 câu',
                                  style: TextStyle(
                                    color: AppColors.primaryYellow,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Số câu',
                                  style: TextStyle(
                                    color: AppColors.grayLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Chọn cấp độ để bắt đầu',
                            style: TextStyle(
                              color: AppColors.grayLight,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButton<String>(
                          value: _selectedLevel,
                          isExpanded: true,
                          dropdownColor: AppColors.primaryBlack,
                          style: const TextStyle(color: AppColors.primaryWhite),
                          items: RoadmapMockData.levels.map((level) {
                            return DropdownMenuItem<String>(
                              value: level.id,
                              child: Text(level.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedLevel = value);
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/roadmap/test', extra: {'level': _selectedLevel});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              foregroundColor: AppColors.primaryBlack,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow),
                                SizedBox(width: 8),
                                Text(
                                  'Bắt đầu ngay',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Lộ trình học tập',
                    style: TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    final section = entry.value;
                    return RoadmapTimelineSection(
                      section: section,
                      index: index,
                      total: sections.length,
                    );
                  }),
                  const SizedBox(height: 32),
                  RoadmapStatsCard(
                    completedDays: completedDays,
                    totalQuestions: totalQuestions,
                    progress: progress,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

