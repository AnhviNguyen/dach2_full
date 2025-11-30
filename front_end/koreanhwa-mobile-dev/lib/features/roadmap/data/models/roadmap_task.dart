class RoadmapTask {
  final String id;
  final String title;
  final String description;
  final String type;
  final int target;
  final int current;
  final bool completed;

  RoadmapTask({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.current,
    this.completed = false,
  });

  factory RoadmapTask.fromJson(Map<String, dynamic> json) {
    return RoadmapTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      target: json['target'] as int,
      current: json['current'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'target': target,
      'current': current,
      'completed': completed,
    };
  }
}

class RoadmapTaskCategory {
  final String category;
  final String icon;
  final List<RoadmapTask> tasks;

  RoadmapTaskCategory({
    required this.category,
    required this.icon,
    required this.tasks,
  });

  factory RoadmapTaskCategory.fromJson(Map<String, dynamic> json) {
    return RoadmapTaskCategory(
      category: json['category'] as String,
      icon: json['icon'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map((t) => RoadmapTask.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

