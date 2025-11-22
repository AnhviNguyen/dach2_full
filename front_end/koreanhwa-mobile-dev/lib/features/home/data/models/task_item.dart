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
}

