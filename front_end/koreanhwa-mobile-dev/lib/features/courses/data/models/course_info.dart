import 'package:flutter/material.dart';

class CourseInfo {
  final int id;
  final String title;
  final String instructor;
  final String level;
  final double rating;
  final int students;
  final int lessons;
  final String duration;
  final String price;
  final String? image;
  final double progress;
  final bool isEnrolled;
  final Color accentColor;

  const CourseInfo({
    required this.id,
    required this.title,
    required this.instructor,
    required this.level,
    required this.rating,
    required this.students,
    required this.lessons,
    required this.duration,
    required this.price,
    this.image,
    this.progress = 0.0,
    this.isEnrolled = false,
    required this.accentColor,
  });
}

