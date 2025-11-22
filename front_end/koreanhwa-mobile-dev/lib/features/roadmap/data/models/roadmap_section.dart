import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_day.dart';

class RoadmapSection {
  final String period;
  final String title;
  final String target;
  final String icon;
  final String color;
  final bool isTest;
  final List<RoadmapDay> days;

  RoadmapSection({
    required this.period,
    required this.title,
    required this.target,
    required this.icon,
    required this.color,
    this.isTest = false,
    required this.days,
  });
}

