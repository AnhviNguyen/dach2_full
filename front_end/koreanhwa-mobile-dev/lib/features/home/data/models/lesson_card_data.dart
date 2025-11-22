import 'package:flutter/material.dart';

class LessonCardData {
  final String title;
  final String date;
  final String tag;
  final Color accentColor;
  final Color backgroundColor;

  const LessonCardData({
    required this.title,
    required this.date,
    required this.tag,
    required this.accentColor,
    required this.backgroundColor,
  });
}

