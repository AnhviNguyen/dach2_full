import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final double height;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AuthHeader({
    super.key,
    this.height = 200,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            color: AppColors.primaryYellow,
            child: Image.asset(
              'lib/utils/images/image.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
          if (showBackButton)
            Positioned(
              top: 16,
              left: 16,
              child: Material(
                color: AppColors.primaryWhite.withOpacity(0.8),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

