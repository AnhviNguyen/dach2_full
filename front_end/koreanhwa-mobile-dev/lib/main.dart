import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:koreanhwa_flutter/shared/routing/app_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_theme.dart';
import 'package:koreanhwa_flutter/controllers/theme_provider.dart';
import 'package:koreanhwa_flutter/controllers/locale_provider.dart';
import 'package:koreanhwa_flutter/services/notification_service.dart';
import 'package:koreanhwa_flutter/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Load settings (this will also load theme and locale preferences)
  await SettingsService.getSettings();
  
  runApp(
    const ProviderScope(
      child: KoreanHwaApp(),
    ),
  );
}

class KoreanHwaApp extends ConsumerWidget {
  const KoreanHwaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'KoreanHwa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      // Localization support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // Vietnamese
        Locale('en', 'US'), // English
        Locale('ko', 'KR'), // Korean
      ],
      locale: locale, // Use locale from provider
    );
  }
}
