class CompetitionResult {
  final int competitionId;
  final String competitionTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final int score;
  final int? rank;
  final bool isWinner;
  final int? prizeAmount;
  final DateTime submittedAt;
  final DateTime? evaluatedAt;
  final String? evaluationStatus; // 'evaluating', 'completed', 'approved'
  final double accuracy;
  final List<QuestionResult> questionResults;

  CompetitionResult({
    required this.competitionId,
    required this.competitionTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedAnswers,
    required this.score,
    this.rank,
    required this.isWinner,
    this.prizeAmount,
    required this.submittedAt,
    this.evaluatedAt,
    this.evaluationStatus,
    required this.accuracy,
    required this.questionResults,
  });

  factory CompetitionResult.fromJson(Map<String, dynamic> json) {
    List<QuestionResult> questionResults = [];
    if (json['questionResults'] != null && json['questionResults'] is List) {
      questionResults = (json['questionResults'] as List<dynamic>)
          .map((q) => QuestionResult.fromJson(q as Map<String, dynamic>))
          .toList();
    }

    return CompetitionResult(
      competitionId: json['competitionId'] as int,
      competitionTitle: '',
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      wrongAnswers: json['wrongAnswers'] as int? ?? 0,
      skippedAnswers: json['skippedAnswers'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      rank: json['rank'] as int?,
      isWinner: (json['rank'] as int?) != null && (json['rank'] as int) <= 3,
      prizeAmount: null,
      submittedAt: DateTime.now(),
      evaluatedAt: null,
      evaluationStatus: 'completed',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      questionResults: questionResults,
    );
  }
}

class QuestionResult {
  final int questionId;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  QuestionResult({
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'] as int,
      userAnswer: json['userAnswer'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }
}

