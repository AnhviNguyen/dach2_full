class ExerciseItem {
  final int id;
  final String type;
  final String question;
  final List<String>? options;
  final int? correct;
  final String? answer;

  const ExerciseItem({
    required this.id,
    required this.type,
    required this.question,
    this.options,
    this.correct,
    this.answer,
  });
}

