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

