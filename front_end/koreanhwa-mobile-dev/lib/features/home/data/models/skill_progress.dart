import 'package:flutter/material.dart';

class SkillProgress {
  final String label;
  final double percent;
  final Color color;

  const SkillProgress({
    required this.label,
    required this.percent,
    required this.color,
  });

  factory SkillProgress.fromJson(Map<String, dynamic> json) {
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

    return SkillProgress(
      label: json['label'] as String? ?? '',
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      color: parseColor(json['color'] as String?),
    );
  }
}

