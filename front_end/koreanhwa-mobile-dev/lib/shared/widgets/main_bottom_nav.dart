import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

enum MainNavItem {
  home,
  curriculum,
  lessons,
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
    MainNavItem.lessons: (icon: Icons.school_rounded, label: 'Khóa học'),
    MainNavItem.vocabulary: (icon: Icons.translate_rounded, label: 'Từ vựng'),
    MainNavItem.settings: (icon: Icons.settings_rounded, label: 'Cài đặt'),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.grayLight, // Use your light gray color from AppColors
            width: 1.0, // Border thickness
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: BottomNavigationBar(
        currentIndex: MainNavItem.values.indexOf(current),
        onTap: (index) => onChanged(MainNavItem.values[index]),
        backgroundColor: const Color(0xFFF7F2DE),
        selectedItemColor: AppColors.primaryBlack,
        unselectedItemColor: AppColors.grayLight,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        items: MainNavItem.values.map((item) {
          final navItem = _navItems[item]!;
          return BottomNavigationBarItem(
            icon: Icon(
              navItem.icon,
              semanticLabel: navItem.label,
              size: 25,
            ),
            label: navItem.label,
          );
        }).toList(),
      ),
    );
  }
}