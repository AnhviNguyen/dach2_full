import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/controllers/theme_provider.dart';

class SettingsAppearanceTab extends ConsumerStatefulWidget {
  const SettingsAppearanceTab({super.key});

  @override
  ConsumerState<SettingsAppearanceTab> createState() => _SettingsAppearanceTabState();
}

class _SettingsAppearanceTabState extends ConsumerState<SettingsAppearanceTab> {
  AppearanceSettings? _appearance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _appearance = settings.appearance;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _appearance == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final appearance = _appearance!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt giao diện',
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
                  'Giao diện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: appearance.theme,
                  decoration: const InputDecoration(
                    labelText: 'Chủ đề',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'light', child: Text('Sáng')),
                    DropdownMenuItem(value: 'dark', child: Text('Tối')),
                    DropdownMenuItem(value: 'auto', child: Text('Tự động')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      // Update theme mode in provider (this will change the app theme immediately)
                      ThemeMode themeMode;
                      switch (value) {
                        case 'light':
                          themeMode = ThemeMode.light;
                          break;
                        case 'dark':
                          themeMode = ThemeMode.dark;
                          break;
                        case 'auto':
                        default:
                          themeMode = ThemeMode.system;
                          break;
                      }
                      ref.read(themeModeProvider.notifier).setThemeMode(themeMode);

                      // Save to settings
                      final updated = AppearanceSettings(
                        theme: value,
                        fontSize: appearance.fontSize,
                        compactMode: appearance.compactMode,
                        showAnimations: appearance.showAnimations,
                        colorScheme: appearance.colorScheme,
                        accentColor: appearance.accentColor,
                        backgroundImage: appearance.backgroundImage,
                        cardStyle: appearance.cardStyle,
                        showAvatars: appearance.showAvatars,
                        showIcons: appearance.showIcons,
                      );
                      await SettingsService.updateAppearance(updated);
                      setState(() {
                        _appearance = updated;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã cập nhật giao diện'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
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

