import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class RoadmapSurveyScreen extends StatefulWidget {
  const RoadmapSurveyScreen({super.key});

  @override
  State<RoadmapSurveyScreen> createState() => _RoadmapSurveyScreenState();
}

class _RoadmapSurveyScreenState extends State<RoadmapSurveyScreen> {
  int _currentStep = 0;
  
  // Survey answers
  bool? _hasLearnedKorean;
  String? _learningReason;
  int? _selfAssessedLevel; // 1-6
  
  final List<String> _learningReasons = [
    'Du học',
    'Công việc',
    'Yêu thích văn hóa Hàn Quốc',
    'Thi TOPIK',
    'Giao tiếp',
    'Khác'
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
          'Khảo sát trình độ',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: AppColors.primaryBlack.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentStep == 0) _buildStep1(),
              if (_currentStep == 1) _buildStep2(),
              if (_currentStep == 2) _buildStep3(),
              const SizedBox(height: 32),
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _currentStep--);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryYellow),
                          foregroundColor: AppColors.primaryYellow,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Quay lại'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _handleNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlack,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: AppColors.primaryBlack.withOpacity(0.3),
                      ),
                      child: Text(
                        _currentStep == 2 ? 'Hoàn thành' : 'Tiếp theo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _hasLearnedKorean != null;
      case 1:
        return _learningReason != null;
      case 2:
        return _selfAssessedLevel != null;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Navigate to placement test with survey data
      context.push('/roadmap/placement', extra: {
        'surveyData': {
          'hasLearnedKorean': _hasLearnedKorean,
          'learningReason': _learningReason,
          'selfAssessedLevel': _selfAssessedLevel,
        },
      });
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 1/3',
          style: TextStyle(
            color: AppColors.primaryYellow,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bạn đã học tiếng Hàn chưa?',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primaryWhite),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Câu trả lời sẽ giúp chúng tôi xây dựng lộ trình phù hợp với bạn',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.grayLight,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        _buildOptionButton(
          label: 'Chưa học',
          isSelected: _hasLearnedKorean == false,
          onTap: () => setState(() => _hasLearnedKorean = false),
        ),
        const SizedBox(height: 16),
        _buildOptionButton(
          label: 'Đã học rồi',
          isSelected: _hasLearnedKorean == true,
          onTap: () => setState(() => _hasLearnedKorean = true),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 2/3',
          style: TextStyle(
            color: AppColors.primaryYellow,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bạn học tiếng Hàn vì lý do gì?',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primaryWhite),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Chọn lý do chính khiến bạn muốn học tiếng Hàn',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.grayLight,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        ..._learningReasons.map((reason) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOptionButton(
              label: reason,
              isSelected: _learningReason == reason,
              onTap: () => setState(() => _learningReason = reason),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 3/3',
          style: TextStyle(
            color: AppColors.primaryYellow,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bạn tự đánh giá mình ở cấp độ nào?',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primaryWhite),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Chọn cấp độ bạn nghĩ mình đang ở (1-6)',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.grayLight,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        ...List.generate(6, (index) {
          final level = index + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOptionButton(
              label: 'Cấp độ $level',
              isSelected: _selfAssessedLevel == level,
              onTap: () => setState(() => _selfAssessedLevel = level),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryYellow
              : (isDark ? AppColors.darkSurface : AppColors.primaryBlack.withOpacity(0.5)),
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
                      : (isDark ? Colors.white : AppColors.primaryWhite),
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
    );
  }
}

