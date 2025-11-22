class Competition {
  final int id;
  final String title;
  final String description;
  final String category; // 'speaking', 'writing', 'listening', 'reading'
  final String difficulty; // 'Dễ', 'Trung bình', 'Khó'
  final String timeLimit;
  final int entryFee;
  final int totalPrize;
  final int participants;
  final DateTime deadline;
  final String status; // 'active', 'upcoming', 'completed'
  final List<String> tags;
  final String? image;
  final CompetitionSubmission? mySubmission;
  final CompetitionStats? stats;

  Competition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.timeLimit,
    required this.entryFee,
    required this.totalPrize,
    required this.participants,
    required this.deadline,
    required this.status,
    required this.tags,
    this.image,
    this.mySubmission,
    this.stats,
  });
}

class CompetitionSubmission {
  final bool submitted;
  final int? score;
  final int? rank;
  final String? feedback;
  final DateTime? submittedAt;

  CompetitionSubmission({
    required this.submitted,
    this.score,
    this.rank,
    this.feedback,
    this.submittedAt,
  });
}

class CompetitionStats {
  final int totalSubmissions;
  final double averageScore;
  final int topScore;
  final double completionRate;

  CompetitionStats({
    required this.totalSubmissions,
    required this.averageScore,
    required this.topScore,
    required this.completionRate,
  });
}

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

class PrizeClaimInfo {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String bankAccount;
  final String bankName;
  final String address;
  final String? note;

  PrizeClaimInfo({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.bankAccount,
    required this.bankName,
    required this.address,
    this.note,
  });
}

