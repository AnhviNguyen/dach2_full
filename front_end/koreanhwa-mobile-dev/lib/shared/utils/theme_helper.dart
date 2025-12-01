import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

/// Helper class để lấy theme-aware colors
class ThemeHelper {
  static Color getScaffoldBackground(BuildContext context) {
    final theme = Theme.of(context);
    return theme.scaffoldBackgroundColor;
  }

  static Color getAppBarBackground(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.appBarTheme.backgroundColor ?? 
           (isDark ? AppColors.darkSurface : AppColors.primaryWhite);
  }

  static Color getAppBarForeground(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.appBarTheme.foregroundColor ?? 
           (isDark ? Colors.white : AppColors.primaryBlack);
  }

  static Color getTextColor(BuildContext context, {bool isTitle = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (isTitle) {
      return theme.textTheme.titleLarge?.color ?? 
             (isDark ? Colors.white : AppColors.primaryBlack);
    }
    return theme.textTheme.bodyLarge?.color ?? 
           (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack);
  }

  static Color getCardColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.cardColor ?? 
           (isDark ? AppColors.darkSurface : Colors.white);
  }
}

