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

  factory CompetitionQuestion.fromJson(Map<String, dynamic> json) {
    List<String> options = [];
    int correctAnswer = 0;

    // Parse options from backend response
    if (json['options'] != null && json['options'] is List) {
      final optionsList = json['options'] as List<dynamic>;
      options = optionsList.map((opt) {
        if (opt is Map<String, dynamic>) {
          return opt['optionText'] as String? ?? '';
        }
        return opt.toString();
      }).toList();

      // Find correct answer index
      for (int i = 0; i < optionsList.length; i++) {
        if (optionsList[i] is Map<String, dynamic>) {
          final opt = optionsList[i] as Map<String, dynamic>;
          if (opt['isCorrect'] == true) {
            correctAnswer = i;
            break;
          }
        }
      }
    }

    // If correctAnswer is in the response, use it
    if (json['correctAnswer'] != null) {
      final correct = json['correctAnswer'] as String?;
      if (correct != null) {
        // Try to find index of correct answer in options
        for (int i = 0; i < options.length; i++) {
          if (options[i] == correct) {
            correctAnswer = i;
            break;
          }
        }
      }
    }

    return CompetitionQuestion(
      id: json['id'] as int,
      category: json['questionType'] as String? ?? 'general',
      categoryKr: json['questionType'] as String? ?? '일반',
      title: '',
      titleKr: '',
      audioUrl: '',
      duration: '',
      transcript: '',
      question: json['questionText'] as String? ?? '',
      questionKr: json['questionText'] as String? ?? '',
      options: options,
      correctAnswer: correctAnswer,
    );
  }
}

