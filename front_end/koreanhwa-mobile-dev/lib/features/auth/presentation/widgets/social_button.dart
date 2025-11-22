import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final Color color;
  final Widget icon;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

