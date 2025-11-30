import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/services/notification_service.dart';
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

  Future<void> _updateNotifications() async {
    await SettingsService.updateNotifications(_notifications);
    
    // Update study reminder notification if enabled
    if (_notifications.studyReminders && _notifications.pushNotifications) {
      // Parse study time from profile settings
      // For now, we'll use a default time (can be improved to get from profile)
      final studyTime = _notifications.studyReminders ? '20:00' : null;
      if (studyTime != null) {
        final parts = studyTime.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 20;
          final minute = int.tryParse(parts[1]) ?? 0;
          await NotificationService.scheduleStudyReminder(
            hour: hour,
            minute: minute,
            message: 'Đã đến giờ học tập rồi! Hãy dành ít phút để học tiếng Hàn nhé! 🔥',
          );
        }
      }
    } else {
      // Cancel reminder if disabled
      await NotificationService.cancelStudyReminder();
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật cài đặt thông báo'),
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
          const Text(
            'Cài đặt thông báo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 24),
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
                  (value) async {
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
                    await _updateNotifications();
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
                        child:                       InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _parseTime(_notifications.quietHours.start),
                          );
                          if (picked != null) {
                            final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
                                  start: timeStr,
                                  end: _notifications.quietHours.end,
                                ),
                              );
                            });
                            await _updateNotifications();
                          }
                        },
                        child: TextFormField(
                          enabled: false,
                          initialValue: _notifications.quietHours.start,
                          decoration: const InputDecoration(
                            labelText: 'Bắt đầu',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                        ),
                      ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child:                       InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _parseTime(_notifications.quietHours.end),
                          );
                          if (picked != null) {
                            final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
                                  end: timeStr,
                                ),
                              );
                            });
                            await _updateNotifications();
                          }
                        },
                        child: TextFormField(
                          enabled: false,
                          initialValue: _notifications.quietHours.end,
                          decoration: const InputDecoration(
                            labelText: 'Kết thúc',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                        ),
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

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Fallback to default
    }
    return const TimeOfDay(hour: 22, minute: 0);
  }
}

