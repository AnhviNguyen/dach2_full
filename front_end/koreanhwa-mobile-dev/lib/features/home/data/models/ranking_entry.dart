import 'package:flutter/material.dart';

class RankingEntry {
  final int position;
  final String name;
  final int points;
  final int days;
  final Color color;

  const RankingEntry({
    required this.position,
    required this.name,
    required this.points,
    required this.days,
    required this.color,
  });
}

