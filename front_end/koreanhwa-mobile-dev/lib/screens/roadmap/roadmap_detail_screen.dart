import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/models/roadmap_model.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class RoadmapDetailScreen extends StatefulWidget {
  const RoadmapDetailScreen({super.key});

  @override
  State<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends State<RoadmapDetailScreen> {
  String _selectedLevel = 'level1';
  final List<Map<String, dynamic>> _levels = [
    {'id': 'level1', 'name': 'Cấp độ 1', 'color': AppColors.success},
    {'id': 'level2', 'name': 'Cấp độ 2', 'color': AppColors.primaryYellow},
    {'id': 'level3', 'name': 'Cấp độ 3', 'color': AppColors.warning},
    {'id': 'level4', 'name': 'Cấp độ 4', 'color': AppColors.error},
  ];

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
                  'Tiến độ: ${completedDays}/18 ngày',
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
                          items: _levels.map((level) {
                            return DropdownMenuItem<String>(
                              value: level['id'],
                              child: Text(level['name']),
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
                    return _buildTimelineSection(section, index, sections.length);
                  }),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$completedDays',
                                  style: const TextStyle(
                                    color: AppColors.primaryYellow,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Ngày hoàn thành',
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
                                  '$totalQuestions',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Câu hỏi đã làm',
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
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: AppColors.info,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Tiến độ tổng thể',
                                  style: TextStyle(
                                    color: AppColors.grayLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(RoadmapSection section, int index, int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryYellow.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _getIcon(section.icon),
                  color: AppColors.primaryBlack,
                  size: 32,
                ),
              ),
              if (index < total - 1)
                Container(
                  width: 2,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryYellow,
                        AppColors.primaryYellow.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.grayLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          section.period,
                          style: const TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (section.isTest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Bài thi thử',
                            style: TextStyle(
                              color: AppColors.primaryBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    section.title,
                    style: const TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (section.target.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      section.target,
                      style: TextStyle(
                        color: AppColors.grayLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (section.days.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...section.days.map((day) => _buildDayCard(day)),
                  ],
                  if (section.isTest) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryYellow,
                            AppColors.primaryYellow.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kiểm tra tổng hợp',
                                style: TextStyle(
                                  color: AppColors.primaryBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Đánh giá toàn diện kiến thức đã học',
                                style: TextStyle(
                                  color: AppColors.primaryBlack,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.emoji_events,
                            color: AppColors.primaryBlack,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(RoadmapDay day) {
    Color bgColor;
    Color textColor;
    IconData statusIcon;

    switch (day.status) {
      case 'completed':
        bgColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'available':
        bgColor = AppColors.primaryYellow.withOpacity(0.2);
        textColor = AppColors.primaryYellow;
        statusIcon = Icons.play_circle;
        break;
      default:
        bgColor = AppColors.grayLight.withOpacity(0.1);
        textColor = AppColors.grayLight;
        statusIcon = Icons.lock;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: day.status == 'completed'
                  ? const Icon(Icons.check, color: AppColors.primaryBlack, size: 20)
                  : Text(
                      '${day.day}',
                      style: TextStyle(
                        color: day.status == 'available' ? AppColors.primaryBlack : AppColors.grayLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.type,
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  day.questions,
                  style: TextStyle(
                    color: AppColors.grayLight,
                    fontSize: 12,
                  ),
                ),
                if (day.hasTest)
                  Text(
                    '• Đánh giá',
                    style: TextStyle(
                      color: AppColors.primaryYellow,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (day.status == 'available')
            ElevatedButton(
              onPressed: () {
                context.push('/roadmap/test', extra: {'level': _selectedLevel});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, size: 16),
                  SizedBox(width: 4),
                  Text('Bắt đầu'),
                ],
              ),
            )
          else
            Icon(statusIcon, color: textColor, size: 24),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'headphones':
        return Icons.headphones;
      case 'users':
        return Icons.people;
      case 'map':
        return Icons.map;
      case 'award':
        return Icons.emoji_events;
      case 'image':
        return Icons.image;
      default:
        return Icons.book;
    }
  }
}

