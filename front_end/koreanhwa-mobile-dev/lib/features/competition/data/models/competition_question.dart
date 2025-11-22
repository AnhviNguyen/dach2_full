class CompetitionQuestion {
  final int id;
  final String category;
  final String categoryKr;
  final String title;
  final String titleKr;
  final String audioUrl;
  final String duration;
  final String transcript;
  final String question;
  final String questionKr;
  final List<String> options;
  final int correctAnswer;

  CompetitionQuestion({
    required this.id,
    required this.category,
    required this.categoryKr,
    required this.title,
    required this.titleKr,
    required this.audioUrl,
    required this.duration,
    required this.transcript,
    required this.question,
    required this.questionKr,
    required this.options,
    required this.correctAnswer,
  });
}

