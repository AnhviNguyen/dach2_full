import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class SettingsMotivationTab extends StatefulWidget {
  const SettingsMotivationTab({super.key});

  @override
  State<SettingsMotivationTab> createState() => _SettingsMotivationTabState();
}

class _SettingsMotivationTabState extends State<SettingsMotivationTab> {
  late MotivationSettings _motivation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _motivation = settings.motivation;
    });
  }

  Future<void> _updateMotivation() async {
    await SettingsService.updateMotivation(_motivation);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật cài đặt động lực'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Settings
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Cài đặt Streak',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.local_fire_department, color: AppColors.warning, size: 24),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_motivation.studyStreak.current}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                            Text(
                              'Streak hiện tại',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grayLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_motivation.studyStreak.longest}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                            Text(
                              'Kỷ lục',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grayLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_motivation.studyStreak.goal}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            Text(
                              'Mục tiêu',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grayLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _motivation.studyStreak.goal.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Mục tiêu streak (ngày)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) async {
                    final goal = int.tryParse(value) ?? _motivation.studyStreak.goal;
                    setState(() {
                      _motivation = MotivationSettings(
                        streakGoal: _motivation.streakGoal,
                        weeklyChallenges: _motivation.weeklyChallenges,
                        achievementDisplay: _motivation.achievementDisplay,
                        progressCelebration: _motivation.progressCelebration,
                        milestoneRewards: _motivation.milestoneRewards,
                        socialFeatures: _motivation.socialFeatures,
                        leaderboardParticipation: _motivation.leaderboardParticipation,
                        customRewards: _motivation.customRewards,
                        motivationMessages: _motivation.motivationMessages,
                        studyStreak: StudyStreak(
                          current: _motivation.studyStreak.current,
                          longest: _motivation.studyStreak.longest,
                          goal: goal,
                          rewards: _motivation.studyStreak.rewards,
                        ),
                      );
                    });
                    await _updateMotivation();
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Phần thưởng streak',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),
                ..._motivation.studyStreak.rewards.map((reward) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.whiteGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          reward.achieved ? Icons.check_circle : Icons.access_time,
                          color: reward.achieved ? AppColors.success : AppColors.grayLight,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${reward.days} ngày',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                reward.reward,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grayLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (reward.achieved)
                          Icon(Icons.emoji_events, color: AppColors.primaryYellow, size: 24),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Achievement Settings
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cài đặt thành tích',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSwitchTile(
                  'Hiển thị thành tích',
                  'Hiển thị thành tích và huy hiệu',
                  _motivation.achievementDisplay,
                  (value) async {
                    setState(() {
                      _motivation = MotivationSettings(
                        streakGoal: _motivation.streakGoal,
                        weeklyChallenges: _motivation.weeklyChallenges,
                        achievementDisplay: value,
                        progressCelebration: _motivation.progressCelebration,
                        milestoneRewards: _motivation.milestoneRewards,
                        socialFeatures: _motivation.socialFeatures,
                        leaderboardParticipation: _motivation.leaderboardParticipation,
                        customRewards: _motivation.customRewards,
                        motivationMessages: _motivation.motivationMessages,
                        studyStreak: _motivation.studyStreak,
                      );
                    });
                    await _updateMotivation();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Thông báo thành tích',
                  'Nhận thông báo khi đạt thành tích mới',
                  _motivation.milestoneRewards,
                  (value) {
                    setState(() {
                      _motivation = MotivationSettings(
                        streakGoal: _motivation.streakGoal,
                        weeklyChallenges: _motivation.weeklyChallenges,
                        achievementDisplay: _motivation.achievementDisplay,
                        progressCelebration: _motivation.progressCelebration,
                        milestoneRewards: value,
                        socialFeatures: _motivation.socialFeatures,
                        leaderboardParticipation: _motivation.leaderboardParticipation,
                        customRewards: _motivation.customRewards,
                        motivationMessages: _motivation.motivationMessages,
                        studyStreak: _motivation.studyStreak,
                      );
                    });
                    _updateMotivation();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Chúc mừng tiến độ',
                  'Hiển thị thông báo chúc mừng khi hoàn thành mục tiêu',
                  _motivation.progressCelebration,
                  (value) {
                    setState(() {
                      _motivation = MotivationSettings(
                        streakGoal: _motivation.streakGoal,
                        weeklyChallenges: _motivation.weeklyChallenges,
                        achievementDisplay: _motivation.achievementDisplay,
                        progressCelebration: value,
                        milestoneRewards: _motivation.milestoneRewards,
                        socialFeatures: _motivation.socialFeatures,
                        leaderboardParticipation: _motivation.leaderboardParticipation,
                        customRewards: _motivation.customRewards,
                        motivationMessages: _motivation.motivationMessages,
                        studyStreak: _motivation.studyStreak,
                      );
                    });
                    _updateMotivation();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.grayLight,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryYellow,
      ),
    );
  }
}

