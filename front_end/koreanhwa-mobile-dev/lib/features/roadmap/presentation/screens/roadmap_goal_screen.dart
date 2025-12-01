import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/services/roadmap_api_service.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_period.dart';
import 'package:koreanhwa_flutter/core/storage/shared_preferences_service.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';

class RoadmapGoalScreen extends StatefulWidget {
  final int currentLevel;
  final Map<String, dynamic> surveyData;

  const RoadmapGoalScreen({
    super.key,
    required this.currentLevel,
    required this.surveyData,
  });

  @override
  State<RoadmapGoalScreen> createState() => _RoadmapGoalScreenState();
}

class _RoadmapGoalScreenState extends State<RoadmapGoalScreen> {
  final RoadmapApiService _apiService = RoadmapApiService();
  int? _targetLevel;
  int? _timelineDays;  // Changed from timelineMonths to timelineDays
  bool _isGenerating = false;

  final List<int> _availableLevels = [1, 2, 3, 4, 5, 6];
  // Timeline options: can be days or months
  // Format: {value: days, label: "display text"}
  final List<Map<String, dynamic>> _timelineOptions = [
    {"value": 30, "label": "30 ngày"},
    {"value": 60, "label": "60 ngày"},
    {"value": 90, "label": "90 ngày"},
    {"value": 120, "label": "4 tháng"},
    {"value": 180, "label": "6 tháng"},
    {"value": 270, "label": "9 tháng"},
    {"value": 360, "label": "12 tháng"},
    {"value": 540, "label": "18 tháng"},
    {"value": 720, "label": "24 tháng"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryBlack,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.primaryWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thiết lập mục tiêu',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current level display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryYellow.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primaryYellow,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cấp độ hiện tại của bạn',
                            style: TextStyle(
                              color: AppColors.grayLight,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cấp độ ${widget.currentLevel}/6',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.titleLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primaryBlack),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Target level selection
              Text(
                'Mục tiêu của bạn',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primaryBlack),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bạn muốn đạt cấp độ TOPIK nào?',
                style: TextStyle(
                  color: AppColors.grayLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableLevels
                    .where((level) => level > widget.currentLevel)
                    .map((level) {
                  final isSelected = _targetLevel == level;
                  return InkWell(
                    onTap: () => setState(() => _targetLevel = level),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryYellow
                            : AppColors.primaryBlack.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryYellow
                              : AppColors.primaryYellow.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'TOPIK $level',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryBlack
                              : AppColors.primaryWhite,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Timeline selection
              Text(
                'Thời gian',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primaryBlack),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bạn muốn đạt mục tiêu trong bao lâu?',
                style: TextStyle(
                  color: AppColors.grayLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ..._timelineOptions.map((option) {
                final days = option['value'] as int;
                final label = option['label'] as String;
                final isSelected = _timelineDays == days;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _timelineDays = days),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryYellow
                            : AppColors.primaryBlack.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryYellow
                              : AppColors.primaryYellow.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryBlack
                                    : AppColors.primaryYellow,
                                width: 2,
                              ),
                              color: isSelected
                                  ? AppColors.primaryBlack
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.primaryYellow,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryBlack
                                    : AppColors.primaryWhite,
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_targetLevel != null &&
                          _timelineDays != null &&
                          !_isGenerating)
                      ? _generateRoadmap
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor:
                        AppColors.primaryBlack.withOpacity(0.3),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBlack,
                            ),
                          ),
                        )
                      : const Text(
                          'Tạo lộ trình',
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
    );
  }

  Future<void> _generateRoadmap() async {
    if (_targetLevel == null || _timelineDays == null) return;

    setState(() => _isGenerating = true);

    try {
      final user = await SharedPreferencesService.getUser();
      if (user == null) {
        throw Exception('User not found');
      }

      // Calculate timeline_months from days (for backward compatibility)
      // Round up to nearest month
      final timelineMonths = (_timelineDays! / 30.0).ceil();

      // Generate roadmap
      final roadmapData = await _apiService.generateRoadmap(
        userId: user.id,
        currentLevel: widget.currentLevel,
        targetLevel: _targetLevel!,
        timelineMonths: timelineMonths,
        timelineDays: _timelineDays!,  // Send actual days
        surveyData: widget.surveyData,
      );

      // Save roadmap data (includes roadmap_id)
      await RoadmapService.saveRoadmapTimeline(roadmapData);

      // Save goal settings
      await SharedPreferencesService.saveTargetScore(
        'Level $_targetLevel',
        0, // Score will be calculated later
      );

      if (mounted) {
        // Navigate to detail screen
        context.pushReplacement('/roadmap/detail');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo lộ trình: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

