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

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    Color parseColor(String? colorStr) {
      if (colorStr == null || colorStr.isEmpty) {
        return Colors.blue;
      }
      try {
        return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.blue;
      }
    }

    return AchievementItem(
      iconLabel: json['iconLabel'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      color: parseColor(json['color'] as String?),
      isCompleted: json['isCompleted'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

