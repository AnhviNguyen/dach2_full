class CompetitionResult {
  final int competitionId;
  final String competitionTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final int rank;
  final bool isWinner;
  final int? prizeAmount;
  final DateTime submittedAt;
  final DateTime? evaluatedAt;
  final String? evaluationStatus; // 'evaluating', 'completed', 'approved'

  CompetitionResult({
    required this.competitionId,
    required this.competitionTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.rank,
    required this.isWinner,
    this.prizeAmount,
    required this.submittedAt,
    this.evaluatedAt,
    this.evaluationStatus,
  });
}

