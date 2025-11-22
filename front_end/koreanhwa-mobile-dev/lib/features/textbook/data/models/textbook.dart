import 'package:flutter/material.dart';

class Textbook {
  final int bookNumber;
  final String title;
  final String subtitle;
  final int totalLessons;
  final int completedLessons;
  final bool isCompleted;
  final bool isLocked;
  final Color color;

  const Textbook({
    required this.bookNumber,
    required this.title,
    required this.subtitle,
    required this.totalLessons,
    required this.completedLessons,
    this.isCompleted = false,
    this.isLocked = false,
    required this.color,
  });
}

