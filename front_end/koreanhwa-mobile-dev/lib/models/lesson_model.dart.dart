class LessonModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int duration; // in minutes
  final bool isCompleted;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.duration = 5,
    this.isCompleted = false,
  });

  LessonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? duration,
    bool? isCompleted,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}