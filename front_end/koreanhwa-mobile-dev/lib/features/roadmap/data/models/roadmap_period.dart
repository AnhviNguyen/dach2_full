import 'package:koreanhwa_flutter/features/roadmap/data/models/roadmap_task.dart';

/// Model cho một giai đoạn trong roadmap timeline
class RoadmapPeriod {
  final String period; // "Ngày 1-10"
  final int startDay;
  final int endDay;
  final String title; // "Giai đoạn nền tảng"
  final String description;
  final List<String> focus; // ["từ vựng cơ bản", "ngữ pháp cơ bản"]
  final List<RoadmapTask> tasks;

  RoadmapPeriod({
    required this.period,
    required this.startDay,
    required this.endDay,
    required this.title,
    required this.description,
    required this.focus,
    required this.tasks,
  });

  factory RoadmapPeriod.fromJson(Map<String, dynamic> json) {
    return RoadmapPeriod(
      period: json['period'] as String,
      startDay: json['start_day'] as int,
      endDay: json['end_day'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      focus: (json['focus'] as List<dynamic>?)
              ?.map((f) => f.toString())
              .toList() ??
          [],
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((t) => RoadmapTask.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'start_day': startDay,
      'end_day': endDay,
      'title': title,
      'description': description,
      'focus': focus,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }
}

/// Model cho roadmap timeline đầy đủ
class RoadmapTimeline {
  final String roadmapId;
  final int userId;
  final int currentLevel;
  final int targetLevel;
  final int timelineMonths;
  final int totalDays;
  final List<RoadmapPeriod> periods;

  RoadmapTimeline({
    required this.roadmapId,
    required this.userId,
    required this.currentLevel,
    required this.targetLevel,
    required this.timelineMonths,
    required this.totalDays,
    required this.periods,
  });

  factory RoadmapTimeline.fromJson(Map<String, dynamic> json) {
    return RoadmapTimeline(
      roadmapId: json['roadmap_id'] as String? ?? '',
      userId: json['user_id'] as int,
      currentLevel: json['current_level'] as int,
      targetLevel: json['target_level'] as int,
      timelineMonths: json['timeline_months'] as int,
      totalDays: json['total_days'] as int,
      periods: (json['periods'] as List<dynamic>?)
              ?.map((p) => RoadmapPeriod.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roadmap_id': roadmapId,
      'user_id': userId,
      'current_level': currentLevel,
      'target_level': targetLevel,
      'timeline_months': timelineMonths,
      'total_days': totalDays,
      'periods': periods.map((p) => p.toJson()).toList(),
    };
  }
}

