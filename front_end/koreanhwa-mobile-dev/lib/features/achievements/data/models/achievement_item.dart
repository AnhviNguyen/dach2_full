import 'package:flutter/material.dart';

class AchievementItem {
  final String iconLabel;
  final String title;
  final String subtitle;
  final int count;
  final Color color;
  final bool isCompleted;
  final double progress;

  const AchievementItem({
    required this.iconLabel,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.color,
    required this.isCompleted,
    required this.progress,
  });
}

