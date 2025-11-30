import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_section.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_task.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/roadmap_mock_data.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/services/roadmap_api_service.dart';
import 'package:koreanhwa_flutter/features/roadmap/presentation/widgets/roadmap_timeline_section.dart';
import 'package:koreanhwa_flutter/features/roadmap/presentation/widgets/roadmap_stats_card.dart';
import 'package:koreanhwa_flutter/core/utils/user_utils.dart';

class RoadmapDetailScreen extends StatefulWidget {
  const RoadmapDetailScreen({super.key});

  @override
  State<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends State<RoadmapDetailScreen> {
  final RoadmapApiService _apiService = RoadmapApiService();
  String _selectedLevel = 'level1';
  List<RoadmapTaskCategory> _taskCategories = [];
  int _userLevel = 1;
  int _textbookUnlock = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoadmapData();
  }

  Future<void> _loadRoadmapData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await UserUtils.getUserId();
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Vui lòng đăng nhập';
        });
        return;
      }

      final roadmapData = await _apiService.getUserRoadmap(userId: userId);
      final tasksData = await _apiService.getRoadmapTasks(userId: userId);

      setState(() {
        _userLevel = roadmapData['level'] as int? ?? 1;
        _textbookUnlock = roadmapData['textbook_unlock'] as int? ?? 0;
        _taskCategories = (tasksData['tasks'] as List<dynamic>?)
                ?.map((cat) => RoadmapTaskCategory.fromJson(cat as Map<String, dynamic>))
                .toList() ??
            [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = RoadmapService.getRoadmapSections();
    final completedDays = RoadmapService.getCompletedDays();
    final totalQuestions = RoadmapService.getTotalQuestions();
    final progress = RoadmapService.getProgress();
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryBlack,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBlack,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlack,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryWhite),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.primaryWhite),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRoadmapData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

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
                  'Cấp độ: $_userLevel',
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primaryWhite),
                tooltip: 'Làm lại bài test',
                onPressed: () => _showResetDialog(context),
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
                  // Level and Textbook Unlock Info
                  Container(
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
                            Icon(Icons.star, color: AppColors.primaryYellow, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Cấp độ của bạn: $_userLevel',
                              style: const TextStyle(
                                color: AppColors.primaryWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (_textbookUnlock > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.lock_open, color: AppColors.success, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Giáo trình quyển 1-$_textbookUnlock đã được mở khóa',
                                  style: TextStyle(
                                    color: AppColors.grayLight,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Nhiệm vụ học tập',
                    style: TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_taskCategories.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlack.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Chưa có nhiệm vụ',
                          style: TextStyle(
                            color: AppColors.grayLight,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._taskCategories.map((category) {
                      return _buildTaskCategory(category);
                    }),
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

  Widget _buildTaskCategory(RoadmapTaskCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
              Icon(
                _getIconForCategory(category.icon),
                color: AppColors.primaryYellow,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                category.category,
                style: const TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...category.tasks.map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(RoadmapTask task) {
    final progress = task.target > 0 ? (task.current / task.target).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task.completed
            ? AppColors.success.withOpacity(0.2)
            : AppColors.primaryBlack.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.completed
              ? AppColors.success
              : AppColors.primaryYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    color: task.completed
                        ? AppColors.success
                        : AppColors.primaryWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (task.completed)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryYellow,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: TextStyle(
              color: AppColors.grayLight,
              fontSize: 13,
            ),
          ),
          if (!task.completed && task.target > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.primaryBlack.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryYellow,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${task.current}/${task.target}',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'book':
        return Icons.book;
      case 'quiz':
        return Icons.quiz;
      case 'mic':
        return Icons.mic;
      default:
        return Icons.task;
    }
  }
  
  Future<void> _showResetDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Làm lại bài kiểm tra'),
        content: const Text(
          'Bạn có chắc chắn muốn làm lại bài kiểm tra đầu vào? Kết quả hiện tại sẽ bị xóa và bạn sẽ phải làm lại từ đầu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.primaryWhite,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      await RoadmapService.clearPlacementResult();
      if (mounted) {
        context.go('/roadmap');
      }
    }
  }
}

