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

    // Parse từ TOPIK API format (từ AI backend)
    if (json['answers'] != null && json['answers'] is List) {
      final answersList = json['answers'] as List<dynamic>;
      options = answersList.map((ans) {
        if (ans is Map<String, dynamic>) {
          return ans['text'] as String? ?? '';
        }
        return ans.toString();
      }).toList();

      // Tìm đáp án đúng (TOPIK format thường có correct_answer hoặc is_correct)
      for (int i = 0; i < answersList.length; i++) {
        if (answersList[i] is Map<String, dynamic>) {
          final ans = answersList[i] as Map<String, dynamic>;
          if (ans['is_correct'] == true || ans['isCorrect'] == true) {
            correctAnswer = i;
            break;
          }
        }
      }
    }
    // Parse từ backend competition format (nếu có)
    else if (json['options'] != null && json['options'] is List) {
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

    // Nếu có correctAnswer trong response, dùng nó
    if (json['correctAnswer'] != null) {
      final correct = json['correctAnswer'];
      if (correct is int) {
        correctAnswer = correct;
      } else if (correct is String) {
        // Try to find index of correct answer in options
        for (int i = 0; i < options.length; i++) {
          if (options[i] == correct) {
            correctAnswer = i;
            break;
          }
        }
      }
    }

    // Parse question text từ TOPIK format
    final prompt = json['prompt'] as String? ?? '';
    final introText = json['intro_text'] as String? ?? '';
    final questionText = prompt.isNotEmpty ? prompt : introText;
    
    // Parse audio URL
    final audioUrl = json['audio_url'] as String? ?? 
                     json['context']?['audio'] as String? ?? '';
    
    // Parse question type
    final questionType = json['question_type'] as String? ?? 'reading';
    final category = questionType == 'listening' ? 'Listening' : 'Reading';
    final categoryKr = questionType == 'listening' ? '듣기' : '읽기';
    
    // Generate unique ID từ question_id hoặc number
    final questionId = json['question_id'] as String? ?? '';
    final number = json['number'] as int? ?? 0;
    final examNumber = json['exam_number'] as String? ?? '';
    final id = questionId.isNotEmpty 
        ? int.tryParse(questionId.replaceAll(RegExp(r'[^0-9]'), '')) ?? (number + 1000)
        : (number + 1000);

    return CompetitionQuestion(
      id: json['id'] as int? ?? id,
      category: json['category'] as String? ?? category,
      categoryKr: json['categoryKr'] as String? ?? categoryKr,
      title: json['title'] as String? ?? '',
      titleKr: json['titleKr'] as String? ?? '',
      audioUrl: audioUrl,
      duration: json['duration'] as String? ?? '30s',
      transcript: json['transcript'] as String? ?? introText,
      question: json['question'] as String? ?? json['questionText'] as String? ?? questionText,
      questionKr: json['questionKr'] as String? ?? questionText,
      options: options,
      correctAnswer: json['correctAnswer'] as int? ?? correctAnswer,
    );
  }
}

