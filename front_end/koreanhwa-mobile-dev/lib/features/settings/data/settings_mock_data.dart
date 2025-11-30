import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/features/settings/data/models/settings_section.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_profile_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_motivation_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_notifications_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_appearance_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_language_tab.dart';

class SettingsMockData {
  static List<SettingsSection> get sections => [
        SettingsSection(
          id: 'profile',
          name: 'Hồ sơ cá nhân',
          description: 'Thông tin cá nhân, mật khẩu, mục tiêu học tập',
          icon: Icons.person,
          type: SettingsSectionType.page,
          builder: () => const SettingsProfileTab(),
        ),
        SettingsSection(
          id: 'notifications',
          name: 'Thông báo',
          description: 'Cài đặt thông báo và âm thanh',
          icon: Icons.notifications,
          type: SettingsSectionType.page,
          builder: () => const SettingsNotificationsTab(),
        ),
        SettingsSection(
          id: 'motivation',
          name: 'Động lực',
          description: 'Theo dõi streak và thành tích',
          icon: Icons.local_fire_department,
          type: SettingsSectionType.page,
          builder: () => const SettingsMotivationTab(),
        ),
        SettingsSection(
          id: 'appearance',
          name: 'Giao diện',
          description: 'Đổi chủ đề và màu sắc',
          icon: Icons.palette,
          type: SettingsSectionType.page,
          builder: () => const SettingsAppearanceTab(),
        ),
        SettingsSection(
          id: 'language',
          name: 'Ngôn ngữ',
          description: 'Chọn ngôn ngữ giao diện',
          icon: Icons.language,
          type: SettingsSectionType.page,
          builder: () => const SettingsLanguageTab(),
        ),
      ];
}

