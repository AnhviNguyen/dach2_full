import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koreanhwa_flutter/shared/routing/app_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_theme.dart';
import 'package:koreanhwa_flutter/controllers/theme_provider.dart';

void main() {
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

    return MaterialApp.router(
      title: 'KoreanHwa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
