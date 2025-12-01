import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/core/storage/shared_preferences_service.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screen/exam_statistics_screen.dart';

class TopikUserProfileCard extends StatefulWidget {
  const TopikUserProfileCard({super.key});

  @override
  State<TopikUserProfileCard> createState() => _TopikUserProfileCardState();
}

class _TopikUserProfileCardState extends State<TopikUserProfileCard> {
  String _username = 'nguyengocanh852002'; // Default
  String _userLevel = 'Korean Learner'; // Default
  DateTime? _examDate;
  String _targetLevel = 'Level 5';
  int _targetScore = 230;
  bool _isEditingDate = false;
  bool _isEditingTarget = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await SharedPreferencesService.getUser();
    if (user != null) {
      setState(() {
        _username = user.username ?? user.name;
        _userLevel = user.level ?? 'Korean Learner';
      });
    }
    await _loadExamSettings();
  }

  Future<void> _loadExamSettings() async {
    final examDate = await SharedPreferencesService.getExamDate();
    final targetScore = await SharedPreferencesService.getTargetScore();
    setState(() {
      _examDate = examDate;
      if (targetScore != null) {
        _targetLevel = targetScore['level'] as String;
        _targetScore = targetScore['score'] as int;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa đặt';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  String _getDaysUntilExam() {
    if (_examDate == null) return 'Chưa đặt';
    final now = DateTime.now();
    final difference = _examDate!.difference(now);
    if (difference.inDays < 0) return 'Đã qua';
    if (difference.inDays == 0) return 'Hôm nay';
    return '${difference.inDays} ngày';
  }

  Future<void> _selectExamDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now().add(const Duration(days: 45)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryYellow,
              onPrimary: AppColors.primaryBlack,
              onSurface: AppColors.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      await SharedPreferencesService.saveExamDate(picked);
      setState(() {
        _examDate = picked;
        _isEditingDate = false;
      });
    }
  }

  Future<void> _showTargetScoreDialog() async {
    final levelController = TextEditingController(text: _targetLevel);
    final scoreController = TextEditingController(text: _targetScore.toString());
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Điểm mục tiêu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: levelController,
              decoration: const InputDecoration(
                labelText: 'Level (ví dụ: Level 5)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: scoreController,
              decoration: const InputDecoration(
                labelText: 'Điểm mục tiêu',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final level = levelController.text.trim();
              final score = int.tryParse(scoreController.text.trim());
              if (level.isNotEmpty && score != null) {
                await SharedPreferencesService.saveTargetScore(level, score);
                setState(() {
                  _targetLevel = level;
                  _targetScore = score;
                  _isEditingTarget = false;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlack,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).cardColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userLevel,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kỳ thi:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const Text(
                  'TOPIK II',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectExamDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ngày dự thi:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryBlack.withOpacity(0.6),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatDate(_examDate),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tới kỳ thi:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryBlack.withOpacity(0.6),
                ),
              ),
              Text(
                _getDaysUntilExam(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _showTargetScoreDialog,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Điểm mục tiêu:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryBlack.withOpacity(0.6),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '$_targetLevel ($_targetScore điểm)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExamStatisticsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart, size: 20),
              label: const Text(
                'Thống kê kết quả',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

