class TopikExam {
  final String examNumber;
  final String? title;
  final int? totalQuestions;

  TopikExam({
    required this.examNumber,
    this.title,
    this.totalQuestions,
  });

  factory TopikExam.fromJson(Map<String, dynamic> json) {
    return TopikExam(
      examNumber: json['examNumber'] as String? ?? json['exam_number'] as String? ?? '',
      title: json['title'] as String?,
      totalQuestions: json['totalQuestions'] as int? ?? json['total_questions'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examNumber': examNumber,
      'title': title,
      'totalQuestions': totalQuestions,
    };
  }

  // Convert to ExamModel for compatibility
  String get id => examNumber;
  String get displayTitle => title ?? 'TOPIK Exam $examNumber';
  String get duration => '110 phút';
  int get participants => 0;
  String get questions => totalQuestions != null ? '$totalQuestions câu hỏi' : 'N/A';
  List<String> get tags => ['TOPIK'];
}

