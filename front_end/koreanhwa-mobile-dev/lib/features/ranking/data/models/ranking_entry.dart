import 'package:flutter/material.dart';

class RankingEntry {
  final int position;
  final String name;
  final int points;
  final int days;
  final bool isCurrentUser;
  final Color? color;

  const RankingEntry({
    required this.position,
    required this.name,
    required this.points,
    required this.days,
    this.isCurrentUser = false,
    this.color,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    Color? parseColor(String? colorStr) {
      if (colorStr == null || colorStr.isEmpty) {
        return null;
      }
      try {
        return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
      } catch (e) {
        return null;
      }
    }

    return RankingEntry(
      position: json['position'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      days: json['days'] as int? ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      color: parseColor(json['color'] as String?),
    );
  }
}

