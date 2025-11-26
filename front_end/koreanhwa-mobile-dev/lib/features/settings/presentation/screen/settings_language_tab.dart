import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/settings_model.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class SettingsLanguageTab extends StatefulWidget {
  const SettingsLanguageTab({super.key});

  @override
  State<SettingsLanguageTab> createState() => _SettingsLanguageTabState();
}

class _SettingsLanguageTabState extends State<SettingsLanguageTab> {
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
              color: AppColors.primaryWhite,
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
                  onChanged: (value) {
                    if (value != null) {
                      SettingsService.updateLanguage(LanguageSettings(
                        interfaceLanguage: value,
                        studyLanguage: language.studyLanguage,
                        subtitles: language.subtitles,
                        pronunciation: language.pronunciation,
                        romanization: language.romanization,
                        translationLanguage: language.translationLanguage,
                        autoTranslate: language.autoTranslate,
                        showBothLanguages: language.showBothLanguages,
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

