import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _keyLocale = 'app_locale';
  
  LocaleNotifier() : super(const Locale('vi', 'VN')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeStr = prefs.getString(_keyLocale);
      if (localeStr != null) {
        final parts = localeStr.split('_');
        if (parts.length == 2) {
          state = Locale(parts[0], parts[1]);
        } else if (parts.length == 1) {
          state = Locale(parts[0]);
        }
      }
    } catch (e) {
      // Keep default locale
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLocale, '${locale.languageCode}_${locale.countryCode ?? ''}');
    } catch (e) {
      // Ignore save error
    }
  }

  Future<void> setLocaleFromCode(String languageCode) async {
    Locale locale;
    switch (languageCode) {
      case 'vi':
        locale = const Locale('vi', 'VN');
        break;
      case 'en':
        locale = const Locale('en', 'US');
        break;
      case 'ko':
        locale = const Locale('ko', 'KR');
        break;
      default:
        locale = const Locale('vi', 'VN');
    }
    await setLocale(locale);
  }
}

