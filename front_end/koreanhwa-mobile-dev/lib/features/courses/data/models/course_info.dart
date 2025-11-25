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

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
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

    return CourseInfo(
      id: json['id'] as int,
      title: json['title'] as String,
      instructor: json['instructor'] as String? ?? '',
      level: json['level'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      students: json['students'] as int? ?? 0,
      lessons: json['lessons'] as int? ?? 0,
      duration: json['duration'] as String? ?? '',
      price: json['price'] as String? ?? '',
      image: json['image'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isEnrolled: json['isEnrolled'] as bool? ?? false,
      accentColor: parseColor(json['accentColor'] as String?),
    );
  }
}

