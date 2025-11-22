import 'package:flutter/material.dart';

class RankingEntry {
  final int position;
  final String name;
  final int points;
  final int days;
  final bool isCurrentUser;

  const RankingEntry({
    required this.position,
    required this.name,
    required this.points,
    required this.days,
    this.isCurrentUser = false,
  });
}

