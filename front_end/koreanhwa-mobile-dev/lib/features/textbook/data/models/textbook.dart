import 'package:flutter/material.dart';

class Textbook {
  final int? id;
  final int bookNumber;
  final String title;
  final String subtitle;
  final int totalLessons;
  final int completedLessons;
  final bool isCompleted;
  final bool isLocked;
  final Color color;

  const Textbook({
    this.id,
    required this.bookNumber,
    required this.title,
    required this.subtitle,
    required this.totalLessons,
    required this.completedLessons,
    this.isCompleted = false,
    this.isLocked = false,
    required this.color,
  });

  factory Textbook.fromJson(Map<String, dynamic> json) {
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

    return Textbook(
      id: json['id'] as int?,
      bookNumber: json['bookNumber'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      totalLessons: json['totalLessons'] as int? ?? 0,
      completedLessons: json['completedLessons'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      color: parseColor(json['color'] as String?),
    );
  }
}

