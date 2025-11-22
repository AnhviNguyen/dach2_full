import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/features/settings/data/models/settings_section.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_profile_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_motivation_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_notifications_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_privacy_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_appearance_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_language_tab.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screen/settings_study_tab.dart';

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
          description: 'Âm báo, lịch nhắc học, cập nhật hệ thống',
          icon: Icons.notifications,
          type: SettingsSectionType.page,
          builder: () => const SettingsNotificationsTab(),
        ),
        SettingsSection(
          id: 'motivation',
          name: 'Động lực',
          description: 'Theo dõi streak, phần thưởng và lời nhắc mỗi ngày',
          icon: Icons.local_fire_department,
          type: SettingsSectionType.page,
          builder: () => const SettingsMotivationTab(),
        ),
        SettingsSection(
          id: 'appearance',
          name: 'Giao diện',
          description: 'Đổi chủ đề, màu sắc và kiểu hiển thị nhanh',
          icon: Icons.palette,
          type: SettingsSectionType.inline,
          builder: () => const SettingsAppearanceTab(),
        ),
        SettingsSection(
          id: 'language',
          name: 'Ngôn ngữ',
          description: 'Chọn ngôn ngữ giao diện và phụ đề',
          icon: Icons.language,
          type: SettingsSectionType.inline,
          builder: () => const SettingsLanguageTab(),
        ),
        SettingsSection(
          id: 'study',
          name: 'Cài đặt học tập',
          description: 'Điều chỉnh mức độ và lịch học',
          icon: Icons.book,
          type: SettingsSectionType.inline,
          builder: () => const SettingsStudyTab(),
        ),
        SettingsSection(
          id: 'privacy',
          name: 'Bảo mật',
          description: 'Quyền riêng tư và dữ liệu tài khoản',
          icon: Icons.lock,
          type: SettingsSectionType.inline,
          builder: () => const SettingsPrivacyTab(),
        ),
      ];
}

