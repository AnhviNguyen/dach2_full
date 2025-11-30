import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/shared/widgets/main_bottom_nav.dart';
import 'package:koreanhwa_flutter/features/settings/data/models/settings_section.dart';
import 'package:koreanhwa_flutter/features/settings/data/settings_mock_data.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/widgets/settings_detail_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  MainNavItem _currentNavItem = MainNavItem.settings;

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
        itemCount: SettingsMockData.sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final section = SettingsMockData.sections[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.primaryBlack.withOpacity(0.08)),
            ),
            child: ListTile(
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsDetailScreen(
                      title: section.name,
                      content: section.builder(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: MainBottomNavBar(
        current: _currentNavItem,
        onChanged: (item) {
          setState(() {
            _currentNavItem = item;
          });
          switch (item) {
            case MainNavItem.home:
              context.go('/home');
              break;
            case MainNavItem.curriculum:
              context.go('/textbook');
              break;
            case MainNavItem.vocabulary:
              context.go('/my-vocabulary');
              break;
            case MainNavItem.settings:
              // Already on settings screen
              break;
          }
        },
      ),
    );
  }
}

