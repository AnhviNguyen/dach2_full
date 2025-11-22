import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/auth/presentation/widgets/social_button.dart';

class SocialLoginSection extends StatelessWidget {
  final Function(String provider)? onSocialLogin;

  const SocialLoginSection({
    super.key,
    this.onSocialLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.grayLight)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  color: AppColors.grayLight,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.grayLight)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButton(
              color: const Color(0xFFDB4437), // Google red
              icon: const Text(
                'G',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                onSocialLogin?.call('google');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đăng nhập bằng Google đang được phát triển')),
                );
              },
            ),
            const SizedBox(width: 16),
            SocialButton(
              color: AppColors.primaryBlack,
              icon: const Icon(
                Icons.apple,
                color: AppColors.primaryWhite,
                size: 20,
              ),
              onPressed: () {
                onSocialLogin?.call('apple');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đăng nhập bằng Apple đang được phát triển')),
                );
              },
            ),
            const SizedBox(width: 16),
            SocialButton(
              color: const Color(0xFF1877F2), // Facebook blue
              icon: const Text(
                'f',
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
              ),
              onPressed: () {
                onSocialLogin?.call('facebook');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đăng nhập bằng Facebook đang được phát triển')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

