class LessonResponse {
  final int id;
  final String title;
  final String level;
  final String duration;
  final int progress;
  final int? lessonNumber;
  final String? videoUrl;
  final List<VocabularyItem> vocabulary;
  final List<GrammarItem> grammar;
  final List<ExerciseItem> exercises;

  LessonResponse({
    required this.id,
    required this.title,
    required this.level,
    required this.duration,
    required this.progress,
    this.lessonNumber,
    this.videoUrl,
    required this.vocabulary,
    required this.grammar,
    required this.exercises,
  });

  factory LessonResponse.fromJson(Map<String, dynamic> json) {
    return LessonResponse(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      level: json['level'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      progress: json['progress'] as int? ?? 0,
      lessonNumber: json['lessonNumber'] as int?,
      videoUrl: json['videoUrl'] as String?,
      vocabulary: (json['vocabulary'] as List<dynamic>?)
              ?.map((item) => VocabularyItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      grammar: (json['grammar'] as List<dynamic>?)
              ?.map((item) => GrammarItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((item) => ExerciseItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class VocabularyItem {
  final String korean;
  final String vietnamese;
  final String pronunciation;
  final String example;

  VocabularyItem({
    required this.korean,
    required this.vietnamese,
    required this.pronunciation,
    required this.example,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      korean: json['korean'] as String? ?? '',
      vietnamese: json['vietnamese'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      example: json['example'] as String? ?? '',
    );
  }
}

class GrammarItem {
  final String title;
  final String explanation;
  final List<String> examples;

  GrammarItem({
    required this.title,
    required this.explanation,
    required this.examples,
  });

  factory GrammarItem.fromJson(Map<String, dynamic> json) {
    return GrammarItem(
      title: json['title'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }
}

class ExerciseItem {
  final int id;
  final String type;
  final String question;
  final List<String> options;
  final int? correct;
  final String? answer;

  ExerciseItem({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    this.correct,
    this.answer,
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      correct: json['correct'] as int?,
      answer: json['answer'] as String?,
    );
  }
}

