import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

enum MainNavItem {
  home,
  curriculum,
  vocabulary,
  settings,
}

class MainBottomNavBar extends StatelessWidget {
  final MainNavItem current;
  final ValueChanged<MainNavItem> onChanged;

  const MainBottomNavBar({
    super.key,
    required this.current,
    required this.onChanged,
  });

  static const _navItems = <MainNavItem, ({IconData icon, String label})>{
    MainNavItem.home: (icon: Icons.home_rounded, label: 'Home'),
    MainNavItem.curriculum: (icon: Icons.menu_book_rounded, label: 'Giáo trình'),
    MainNavItem.vocabulary: (icon: Icons.translate_rounded, label: 'Từ vựng'),
    MainNavItem.settings: (icon: Icons.settings_rounded, label: 'Cài đặt'),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomNavColor = isDark ? AppColors.darkSurface : const Color(0xFFF7F2DE);
    final selectedColor = isDark ? AppColors.primaryYellow : AppColors.primaryBlack;
    final unselectedColor = isDark ? AppColors.grayLight : AppColors.grayLight;
    
    return Container(
      decoration: BoxDecoration(
        color: bottomNavColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.keys.map((item) {
              final isSelected = item == current;
              final navItem = _navItems[item]!;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(item),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with animated container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.primaryYellow.withOpacity(0.2) : AppColors.primaryBlack.withOpacity(0.1))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            navItem.icon,
                            size: 26,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Label
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: isSelected ? 11 : 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                          child: Text(
                            navItem.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Active indicator
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: isSelected ? 20 : 0,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}