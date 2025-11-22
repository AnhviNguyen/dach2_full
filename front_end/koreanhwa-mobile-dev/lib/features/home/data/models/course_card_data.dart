import 'package:flutter/material.dart';

class CourseCardData {
  final String title;
  final double progress;
  final int lessons;
  final int completed;
  final Color accentColor;

  const CourseCardData({
    required this.title,
    required this.progress,
    required this.lessons,
    required this.completed,
    required this.accentColor,
  });
}

