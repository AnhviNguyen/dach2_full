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

