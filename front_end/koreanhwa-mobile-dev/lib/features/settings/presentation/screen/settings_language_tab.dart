import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/controllers/locale_provider.dart';

class SettingsLanguageTab extends ConsumerStatefulWidget {
  const SettingsLanguageTab({super.key});

  @override
  ConsumerState<SettingsLanguageTab> createState() => _SettingsLanguageTabState();
}

class _SettingsLanguageTabState extends ConsumerState<SettingsLanguageTab> {
  LanguageSettings? _language;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _language = settings.language;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _language == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final language = _language!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt ngôn ngữ',
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
                  'Ngôn ngữ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: language.interfaceLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Ngôn ngữ giao diện',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ko', child: Text('한국어')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      // Update app locale immediately
                      await ref.read(localeProvider.notifier).setLocaleFromCode(value);

                      // Save to settings
                      final updated = LanguageSettings(
                        interfaceLanguage: value,
                        studyLanguage: language.studyLanguage,
                        subtitles: language.subtitles,
                        pronunciation: language.pronunciation,
                        romanization: language.romanization,
                        translationLanguage: language.translationLanguage,
                        autoTranslate: language.autoTranslate,
                        showBothLanguages: language.showBothLanguages,
                      );
                      await SettingsService.updateLanguage(updated);
                      setState(() {
                        _language = updated;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã cập nhật ngôn ngữ'),
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

