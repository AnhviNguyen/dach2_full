import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_period.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_task.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/services/roadmap_api_service.dart';
import 'package:koreanhwa_flutter/core/utils/user_utils.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';

class RoadmapTimelinePeriod extends StatefulWidget {
  final RoadmapPeriod period;
  final int index;
  final int total;
  final Function(RoadmapTask)? onTaskCompleted;

  const RoadmapTimelinePeriod({
    super.key,
    required this.period,
    required this.index,
    required this.total,
    this.onTaskCompleted,
  });

  @override
  State<RoadmapTimelinePeriod> createState() => _RoadmapTimelinePeriodState();
}

class _RoadmapTimelinePeriodState extends State<RoadmapTimelinePeriod> {
  final RoadmapApiService _apiService = RoadmapApiService();
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryYellow,
                  border: Border.all(
                    color: AppColors.primaryBlack,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: AppColors.primaryBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (widget.index < widget.total - 1)
                Container(
                  width: 2,
                  height: 100,
                  color: AppColors.primaryYellow.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Period content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.period.period,
                              style: TextStyle(
                                color: AppColors.primaryYellow,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.period.title,
                              style: TextStyle(
                                color: Theme.of(context).cardColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.period.description,
                    style: TextStyle(
                      color: AppColors.grayLight,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (widget.period.focus.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.period.focus.map((f) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryYellow.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: AppColors.primaryYellow,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Tasks
                  ...widget.period.tasks.map((task) {
                    return _buildTaskItem(task);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(RoadmapTask task) {
    final progress = task.target > 0
        ? (task.current / task.target).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = task.completed || progress >= 1.0;
    final isAvailable = _isTaskAvailable(task);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isAvailable && !isCompleted ? () => _handleTaskTap(task) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success.withOpacity(0.2)
                : isAvailable
                    ? AppColors.primaryBlack.withOpacity(0.3)
                    : AppColors.primaryBlack.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? AppColors.success
                  : isAvailable
                      ? AppColors.primaryYellow.withOpacity(0.5)
                      : AppColors.grayLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.success
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.primaryYellow,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white, // Icon trắng trên nền màu
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: isCompleted
                                  ? AppColors.success
                                  : isAvailable
                                      ? AppColors.primaryWhite
                                      : AppColors.grayLight,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (task.days != null && task.days!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Ngày ${task.days!.first}',
                              style: TextStyle(
                                color: AppColors.primaryYellow,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        color: AppColors.grayLight,
                        fontSize: 12,
                      ),
                    ),
                    if (!isCompleted && task.target > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  AppColors.primaryBlack.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryYellow,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${task.current}/${task.target}',
                            style: TextStyle(
                              color: AppColors.primaryYellow,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!isAvailable && !isCompleted)
                Icon(
                  Icons.lock,
                  color: AppColors.grayLight,
                  size: 20,
                )
              else if (isAvailable && !isCompleted)
                IconButton(
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 24,
                  ),
                  onPressed: () => _markTaskCompleted(task),
                  tooltip: 'Đánh dấu hoàn thành',
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isTaskAvailable(RoadmapTask task) {
    // Task is available if:
    // 1. It's completed, or
    // 2. It has no days specified (always available), or
    // 3. Today is one of the specified days, or
    // 4. Today is past the first day
    if (task.completed) return true;
    if (task.days == null || task.days!.isEmpty) return true;

    final today = DateTime.now();
    final startDate = DateTime.now(); // Assume roadmap starts today
    final daysSinceStart = today.difference(startDate).inDays + 1;

    // Check if today is one of the task days
    return task.days!.any((day) => day <= daysSinceStart);
  }

  Future<void> _handleTaskTap(RoadmapTask task) async {
    if (_isUpdating) return;

    // Show dialog to confirm or mark as completed
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryBlack,
        title: Text(
          task.title,
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          task.description,
          style: TextStyle(
            color: AppColors.grayLight,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.grayLight),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'navigate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlack,
            ),
            child: const Text('Bắt đầu'),
          ),
          if (!task.completed)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'mark_completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.primaryWhite,
              ),
              child: const Text('Đánh dấu hoàn thành'),
            ),
        ],
      ),
    );

    if (result == 'navigate') {
      // Navigate to the appropriate feature
      await _navigateToTask(task);
    } else if (result == 'mark_completed') {
      // Mark as completed directly
      await _markTaskCompleted(task);
    }
  }

  Future<void> _navigateToTask(RoadmapTask task) async {
    switch (task.type) {
      case 'textbook_learn':
      case 'textbook_vocab':
      case 'textbook_grammar':
      case 'textbook_exercise':
      case 'textbook_chat':
        context.push('/textbook');
        break;

      case 'vocab_flashcard':
      case 'vocab_match':
      case 'vocab_pronunciation':
      case 'vocab_listen_write':
      case 'vocab_quiz':
      case 'vocab_test':
        // Navigate to vocabulary with default book/lesson
        context.push('/vocabulary?bookId=1&lessonId=1');
        break;

      case 'topik_practice':
      case 'topik_listening':
      case 'topik_reading':
        context.push('/topik-library');
        break;

      case 'speak_pronunciation':
      case 'speak_free':
      case 'speak_live_talk':
        context.push('/speak-practice');
        break;

      case 'grammar_learn':
      case 'grammar_exercise':
        context.push('/textbook');
        break;

      default:
        // Default to textbook
        context.push('/textbook');
    }
  }

  Future<void> _markTaskCompleted(RoadmapTask task) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      final userId = await UserUtils.getUserId();
      if (userId == null) return;

      // Get roadmap_id from service
      final roadmapId = await RoadmapService.loadRoadmapId();

      await _apiService.updateTaskStatus(
        userId: userId,
        taskId: task.id,
        completed: true,
        roadmapId: roadmapId,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primaryWhite),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đã hoàn thành: ${task.title}',
                    style: const TextStyle(color: AppColors.primaryWhite),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Callback to parent to refresh and find next task
      if (widget.onTaskCompleted != null) {
        widget.onTaskCompleted!(task);
      }

      // Wait a bit then show next task hint
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        _showNextTaskHint();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật task: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _showNextTaskHint() {
    // Find next incomplete task in this period
    final incompleteTasks = widget.period.tasks.where((t) => !t.completed).toList();
    
    if (incompleteTasks.isNotEmpty) {
      final nextTask = incompleteTasks.first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.arrow_forward, color: AppColors.primaryWhite),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Task tiếp theo: ${nextTask.title}',
                  style: const TextStyle(color: AppColors.primaryWhite),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryYellow,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // All tasks in this period are completed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: AppColors.primaryWhite),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tuyệt vời! Bạn đã hoàn thành tất cả tasks trong giai đoạn này!',
                  style: TextStyle(color: AppColors.primaryWhite),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

