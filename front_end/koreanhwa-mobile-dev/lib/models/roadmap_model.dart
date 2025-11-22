class RoadmapPlacementResult {
  final int level; // 1-4
  final int score;
  final DateTime completedAt;

  RoadmapPlacementResult({
    required this.level,
    required this.score,
    required this.completedAt,
  });
}

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

class RoadmapDay {
  final int day;
  final String type;
  final String questions;
  final String status; // 'completed', 'available', 'locked'
  final bool hasTest;

  RoadmapDay({
    required this.day,
    required this.type,
    required this.questions,
    required this.status,
    required this.hasTest,
  });
}

