import 'package:flutter/material.dart';

class TaskItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color progressColor;
  final double progressPercent;

  const TaskItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.progressColor,
    required this.progressPercent,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    IconData parseIcon(String? iconName) {
      switch (iconName?.toLowerCase()) {
        case 'book':
        case 'book_outlined':
        case 'bookopen':
          return Icons.book_outlined;
        case 'translate':
          return Icons.translate;
        case 'menu_book':
        case 'menu_book_outlined':
          return Icons.menu_book_outlined;
        case 'filetext':
          return Icons.description;
        case 'play':
          return Icons.play_circle_outline;
        case 'edit':
          return Icons.edit;
        case 'hearing':
          return Icons.hearing;
        case 'mic':
          return Icons.mic;
        case 'checksquare':
          return Icons.check_box;
        case 'task':
        default:
          return Icons.task;
      }
    }

    Color parseColor(String? colorStr) {
      if (colorStr == null || colorStr.isEmpty) {
        return Colors.grey;
      }
      try {
        return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.grey;
      }
    }

    return TaskItem(
      title: json['title'] as String? ?? '',
      icon: parseIcon(json['icon'] as String?),
      color: parseColor(json['color'] as String?),
      progressColor: parseColor(json['progressColor'] as String?),
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

