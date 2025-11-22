class ExamModel {
  final String id;
  final String title;
  final String duration;
  final int participants;
  final String questions;
  final List<String> tags;

  ExamModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.participants,
    required this.questions,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'participants': participants,
      'questions': questions,
      'tags': tags,
    };
  }

  factory ExamModel.fromMap(Map<String, dynamic> map) {
    return ExamModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      duration: map['duration'] ?? '',
      participants: map['participants'] ?? 0,
      questions: map['questions'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}

class ExamCategory {
  final String id;
  final String name;

  const ExamCategory({
    required this.id,
    required this.name,
  });
}

class TestSection {
  final String id;
  final String name;
  final int questionCount;
  final bool isSelected;

  TestSection({
    required this.id,
    required this.name,
    required this.questionCount,
    this.isSelected = false,
  });

  TestSection copyWith({
    String? id,
    String? name,
    int? questionCount,
    bool? isSelected,
  }) {
    return TestSection(
      id: id ?? this.id,
      name: name ?? this.name,
      questionCount: questionCount ?? this.questionCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

