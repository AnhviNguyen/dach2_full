import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final bool isActive;

  const OnboardingPageIndicator({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryYellow : AppColors.grayLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

