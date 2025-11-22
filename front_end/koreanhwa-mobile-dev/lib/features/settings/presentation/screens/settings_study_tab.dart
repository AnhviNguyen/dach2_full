import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class SettingsStudyTab extends StatelessWidget {
  const SettingsStudyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final study = SettingsService.getSettings().study;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt học tập',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mục tiêu học tập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: study.dailyGoal.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Mục tiêu hàng ngày (phút)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final goal = int.tryParse(value) ?? study.dailyGoal;
                    SettingsService.updateStudy(StudySettings(
                      dailyGoal: goal,
                      weeklyGoal: study.weeklyGoal,
                      autoPlayAudio: study.autoPlayAudio,
                      showHints: study.showHints,
                      autoSave: study.autoSave,
                      reviewInterval: study.reviewInterval,
                      spacedRepetition: study.spacedRepetition,
                      difficultyAdjustment: study.difficultyAdjustment,
                      focusMode: study.focusMode,
                      studyBreaks: study.studyBreaks,
                      learningPath: study.learningPath,
                      practiceMode: study.practiceMode,
                      vocabularyLimit: study.vocabularyLimit,
                      grammarFocus: study.grammarFocus,
                    ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

