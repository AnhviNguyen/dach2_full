import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class SettingsNotificationsTab extends StatefulWidget {
  const SettingsNotificationsTab({super.key});

  @override
  State<SettingsNotificationsTab> createState() => _SettingsNotificationsTabState();
}

class _SettingsNotificationsTabState extends State<SettingsNotificationsTab> {
  late NotificationSettings _notifications;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _notifications = settings.notifications;
    });
  }

  void _updateNotifications() {
    SettingsService.updateNotifications(_notifications);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt thông báo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 24),
          // Email Notifications
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
                  'Thông báo Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  'Nhận thông báo qua email',
                  'Nhận email về các cập nhật và thông báo quan trọng',
                  _notifications.emailNotifications,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: value,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Push Notifications
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
                  'Thông báo đẩy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  'Bật thông báo đẩy',
                  'Nhận thông báo trên thiết bị của bạn',
                  _notifications.pushNotifications,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: value,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Nhắc nhở học tập',
                  'Nhận thông báo nhắc nhở học tập hàng ngày',
                  _notifications.studyReminders,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: value,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Cập nhật cuộc thi',
                  'Thông báo về các cuộc thi mới và kết quả',
                  _notifications.competitionUpdates,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: value,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Cập nhật blog',
                  'Thông báo về bài viết mới và tương tác',
                  _notifications.blogUpdates,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: value,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Báo cáo hàng tuần',
                  'Nhận báo cáo tiến độ học tập hàng tuần',
                  _notifications.weeklyReports,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: value,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Mục tiêu hàng ngày',
                  'Thông báo về mục tiêu học tập hàng ngày',
                  _notifications.dailyGoals,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: value,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Cảnh báo streak',
                  'Thông báo khi streak sắp bị mất',
                  _notifications.streakAlerts,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: value,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Thông báo thành tích',
                  'Thông báo khi đạt thành tích mới',
                  _notifications.achievementAlerts,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: value,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Hoạt động bạn bè',
                  'Thông báo về hoạt động của bạn bè',
                  _notifications.friendActivity,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: value,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Sound & Vibration
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
                  'Âm thanh & Rung',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  'Bật âm thanh',
                  'Phát âm thanh khi có thông báo',
                  _notifications.soundEnabled,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: value,
                        vibrationEnabled: _notifications.vibrationEnabled,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(),
                _buildSwitchTile(
                  'Bật rung',
                  'Rung thiết bị khi có thông báo',
                  _notifications.vibrationEnabled,
                  (value) {
                    setState(() {
                      _notifications = NotificationSettings(
                        emailNotifications: _notifications.emailNotifications,
                        pushNotifications: _notifications.pushNotifications,
                        studyReminders: _notifications.studyReminders,
                        competitionUpdates: _notifications.competitionUpdates,
                        blogUpdates: _notifications.blogUpdates,
                        weeklyReports: _notifications.weeklyReports,
                        dailyGoals: _notifications.dailyGoals,
                        streakAlerts: _notifications.streakAlerts,
                        achievementAlerts: _notifications.achievementAlerts,
                        friendActivity: _notifications.friendActivity,
                        soundEnabled: _notifications.soundEnabled,
                        vibrationEnabled: value,
                        quietHours: _notifications.quietHours,
                      );
                    });
                    _updateNotifications();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quiet Hours
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Giờ yên tĩnh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    Switch(
                      value: _notifications.quietHours.enabled,
                      onChanged: (value) {
                        setState(() {
                          _notifications = NotificationSettings(
                            emailNotifications: _notifications.emailNotifications,
                            pushNotifications: _notifications.pushNotifications,
                            studyReminders: _notifications.studyReminders,
                            competitionUpdates: _notifications.competitionUpdates,
                            blogUpdates: _notifications.blogUpdates,
                            weeklyReports: _notifications.weeklyReports,
                            dailyGoals: _notifications.dailyGoals,
                            streakAlerts: _notifications.streakAlerts,
                            achievementAlerts: _notifications.achievementAlerts,
                            friendActivity: _notifications.friendActivity,
                            soundEnabled: _notifications.soundEnabled,
                            vibrationEnabled: _notifications.vibrationEnabled,
                            quietHours: QuietHours(
                              enabled: value,
                              start: _notifications.quietHours.start,
                              end: _notifications.quietHours.end,
                            ),
                          );
                        });
                        _updateNotifications();
                      },
                      activeColor: AppColors.primaryYellow,
                    ),
                  ],
                ),
                if (_notifications.quietHours.enabled) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _notifications.quietHours.start,
                          decoration: const InputDecoration(
                            labelText: 'Bắt đầu',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _notifications = NotificationSettings(
                                emailNotifications: _notifications.emailNotifications,
                                pushNotifications: _notifications.pushNotifications,
                                studyReminders: _notifications.studyReminders,
                                competitionUpdates: _notifications.competitionUpdates,
                                blogUpdates: _notifications.blogUpdates,
                                weeklyReports: _notifications.weeklyReports,
                                dailyGoals: _notifications.dailyGoals,
                                streakAlerts: _notifications.streakAlerts,
                                achievementAlerts: _notifications.achievementAlerts,
                                friendActivity: _notifications.friendActivity,
                                soundEnabled: _notifications.soundEnabled,
                                vibrationEnabled: _notifications.vibrationEnabled,
                                quietHours: QuietHours(
                                  enabled: _notifications.quietHours.enabled,
                                  start: value,
                                  end: _notifications.quietHours.end,
                                ),
                              );
                            });
                            _updateNotifications();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _notifications.quietHours.end,
                          decoration: const InputDecoration(
                            labelText: 'Kết thúc',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _notifications = NotificationSettings(
                                emailNotifications: _notifications.emailNotifications,
                                pushNotifications: _notifications.pushNotifications,
                                studyReminders: _notifications.studyReminders,
                                competitionUpdates: _notifications.competitionUpdates,
                                blogUpdates: _notifications.blogUpdates,
                                weeklyReports: _notifications.weeklyReports,
                                dailyGoals: _notifications.dailyGoals,
                                streakAlerts: _notifications.streakAlerts,
                                achievementAlerts: _notifications.achievementAlerts,
                                friendActivity: _notifications.friendActivity,
                                soundEnabled: _notifications.soundEnabled,
                                vibrationEnabled: _notifications.vibrationEnabled,
                                quietHours: QuietHours(
                                  enabled: _notifications.quietHours.enabled,
                                  start: _notifications.quietHours.start,
                                  end: value,
                                ),
                              );
                            });
                            _updateNotifications();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
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

