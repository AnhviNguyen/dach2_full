import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class SettingsPrivacyTab extends StatefulWidget {
  const SettingsPrivacyTab({super.key});

  @override
  State<SettingsPrivacyTab> createState() => _SettingsPrivacyTabState();
}

class _SettingsPrivacyTabState extends State<SettingsPrivacyTab> {
  PrivacySettings? _privacy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _privacy = settings.privacy;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _privacy == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final privacy = _privacy!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt bảo mật',
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quyền riêng tư',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: privacy.profileVisibility,
                  decoration: const InputDecoration(
                    labelText: 'Hiển thị hồ sơ',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'public', child: Text('Công khai')),
                    DropdownMenuItem(value: 'friends', child: Text('Chỉ bạn bè')),
                    DropdownMenuItem(value: 'private', child: Text('Riêng tư')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      SettingsService.updatePrivacy(PrivacySettings(
                        profileVisibility: value,
                        showProgress: privacy.showProgress,
                        showAchievements: privacy.showAchievements,
                        allowMessages: privacy.allowMessages,
                        dataSharing: privacy.dataSharing,
                        showOnlineStatus: privacy.showOnlineStatus,
                        allowFriendRequests: privacy.allowFriendRequests,
                        showEmail: privacy.showEmail,
                        showPhone: privacy.showPhone,
                        allowAnalytics: privacy.allowAnalytics,
                      ));
                    }
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

