import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/screens/settings/settings_profile_tab.dart';
import 'package:koreanhwa_flutter/screens/settings/settings_motivation_tab.dart';
import 'package:koreanhwa_flutter/screens/settings/settings_notifications_tab.dart';
import 'package:koreanhwa_flutter/screens/settings/settings_privacy_tab.dart';
import 'package:koreanhwa_flutter/screens/settings/settings_appearance_tab.dart';
import 'package:koreanhwa_flutter/screens/settings/settings_language_tab.dart';
import 'package:koreanhwa_flutter/screens/settings/settings_study_tab.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<_SettingsSection> _sections = [
    _SettingsSection(
      id: 'profile',
      name: 'Hồ sơ cá nhân',
      description: 'Thông tin cá nhân, mật khẩu, mục tiêu học tập',
      icon: Icons.person,
      type: _SectionType.page,
      builder: () => const SettingsProfileTab(),
    ),
    _SettingsSection(
      id: 'notifications',
      name: 'Thông báo',
      description: 'Âm báo, lịch nhắc học, cập nhật hệ thống',
      icon: Icons.notifications,
      type: _SectionType.page,
      builder: () => const SettingsNotificationsTab(),
    ),
    _SettingsSection(
      id: 'motivation',
      name: 'Động lực',
      description: 'Theo dõi streak, phần thưởng và lời nhắc mỗi ngày',
      icon: Icons.local_fire_department,
      type: _SectionType.page,
      builder: () => const SettingsMotivationTab(),
    ),
    _SettingsSection(
      id: 'appearance',
      name: 'Giao diện',
      description: 'Đổi chủ đề, màu sắc và kiểu hiển thị nhanh',
      icon: Icons.palette,
      type: _SectionType.inline,
      builder: () => const SettingsAppearanceTab(),
    ),
    _SettingsSection(
      id: 'language',
      name: 'Ngôn ngữ',
      description: 'Chọn ngôn ngữ giao diện và phụ đề',
      icon: Icons.language,
      type: _SectionType.inline,
      builder: () => const SettingsLanguageTab(),
    ),
    _SettingsSection(
      id: 'study',
      name: 'Cài đặt học tập',
      description: 'Điều chỉnh mức độ và lịch học',
      icon: Icons.book,
      type: _SectionType.inline,
      builder: () => const SettingsStudyTab(),
    ),
    _SettingsSection(
      id: 'privacy',
      name: 'Bảo mật',
      description: 'Quyền riêng tư và dữ liệu tài khoản',
      icon: Icons.lock,
      type: _SectionType.inline,
      builder: () => const SettingsPrivacyTab(),
    ),
  ];

  void _openDetail(_SettingsSection section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsDetailScreen(
          title: section.name,
          content: section.builder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              SettingsService.saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu thay đổi')),
              );
            },
            icon: const Icon(Icons.save, color: AppColors.primaryBlack),
            label: const Text(
              'Lưu',
              style: TextStyle(color: AppColors.primaryBlack),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.primaryBlack.withOpacity(0.08)),
            ),
            child: section.type == _SectionType.inline
                ? ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Icon(section.icon, color: AppColors.primaryBlack),
                    title: Text(
                      section.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    subtitle: Text(
                      section.description,
                      style: TextStyle(
                        color: AppColors.primaryBlack.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        constraints: const BoxConstraints(maxHeight: 420),
                        width: double.infinity,
                        child: section.builder(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
                : ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(section.icon, color: AppColors.primaryBlack),
                    ),
                    title: Text(
                      section.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    subtitle: Text(
                      section.description,
                      style: TextStyle(
                        color: AppColors.primaryBlack.withOpacity(0.6),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openDetail(section),
                  ),
          );
        },
      ),
    );
  }
}

class SettingsDetailScreen extends StatelessWidget {
  final String title;
  final Widget content;

  const SettingsDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: content,
    );
  }
}

class _SettingsSection {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final _SectionType type;
  final Widget Function() builder;

  const _SettingsSection({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.builder,
  });
}

enum _SectionType { inline, page }
