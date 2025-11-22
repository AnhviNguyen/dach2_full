import 'package:koreanhwa_flutter/models/competition_model.dart';

class CompetitionService {
  static List<Competition> _competitions = [
    Competition(
      id: 1,
      title: 'Cuộc thi phát âm tiếng Hàn 2024',
      description: 'Thể hiện khả năng phát âm chuẩn xác và tự nhiên như người Hàn Quốc',
      category: 'speaking',
      difficulty: 'Trung bình',
      timeLimit: '30 phút',
      entryFee: 0,
      totalPrize: 5000000,
      participants: 156,
      deadline: DateTime(2024, 2, 15),
      status: 'active',
      tags: ['Phát âm', 'Giao tiếp', 'Thực hành'],
      image: null,
      mySubmission: CompetitionSubmission(
        submitted: true,
        score: 85,
        rank: 12,
        feedback: 'Phát âm tốt, cần cải thiện ngữ điệu',
        submittedAt: DateTime(2024, 1, 20),
      ),
      stats: CompetitionStats(
        totalSubmissions: 156,
        averageScore: 78,
        topScore: 95,
        completionRate: 85,
      ),
    ),
    Competition(
      id: 2,
      title: 'Viết văn tiếng Hàn sáng tạo',
      description: 'Sáng tác một bài văn ngắn bằng tiếng Hàn về chủ đề tự chọn',
      category: 'writing',
      difficulty: 'Khó',
      timeLimit: '60 phút',
      entryFee: 50000,
      totalPrize: 3000000,
      participants: 89,
      deadline: DateTime(2024, 2, 20),
      status: 'active',
      tags: ['Viết văn', 'Sáng tạo', 'Ngữ pháp'],
      image: null,
      mySubmission: CompetitionSubmission(
        submitted: false,
      ),
      stats: CompetitionStats(
        totalSubmissions: 89,
        averageScore: 72,
        topScore: 88,
        completionRate: 65,
      ),
    ),
    Competition(
      id: 3,
      title: 'Nghe hiểu tin tức Hàn Quốc',
      description: 'Nghe và trả lời câu hỏi về tin tức thời sự Hàn Quốc',
      category: 'listening',
      difficulty: 'Dễ',
      timeLimit: '45 phút',
      entryFee: 0,
      totalPrize: 2000000,
      participants: 234,
      deadline: DateTime(2024, 2, 10),
      status: 'upcoming',
      tags: ['Nghe hiểu', 'Tin tức', 'Thời sự'],
      image: null,
      mySubmission: CompetitionSubmission(
        submitted: false,
      ),
      stats: CompetitionStats(
        totalSubmissions: 0,
        averageScore: 0,
        topScore: 0,
        completionRate: 0,
      ),
    ),
  ];

  static List<CompetitionQuestion> _questions = [
    CompetitionQuestion(
      id: 1,
      category: 'Chính trị',
      categoryKr: '정치',
      title: 'Hội nghị thượng đỉnh Hàn-Việt 2025',
      titleKr: '2025 한-베트남 정상회담',
      audioUrl: '/audio/korea-vietnam-summit.mp3',
      duration: '2:30',
      transcript: '한국과 베트남 정상이 양국 간 경제 협력 강화 방안을 논의했습니다...',
      question: 'Theo tin tức, hai nước đã thống nhất hợp tác trong những lĩnh vực nào?',
      questionKr: '뉴스에 따르면, 양국은 어떤 분야에서 협력하기로 합의했나요?',
      options: [
        'Chuyển đổi số, năng lượng xanh, trao đổi văn hóa',
        'Nông nghiệp, du lịch, giáo dục',
        'Quốc phòng, y tế, thể thao',
        'Công nghiệp, thương mại, giao thông',
      ],
      correctAnswer: 0,
    ),
  ];

  static List<CompetitionResult> _results = [];

  static List<Competition> getCompetitions({
    String? category,
    String? status,
    String? sortBy,
  }) {
    var filtered = List<Competition>.from(_competitions);

    if (category != null && category != 'all') {
      filtered = filtered.where((c) => c.category == category).toList();
    }

    if (status != null) {
      filtered = filtered.where((c) => c.status == status).toList();
    }

    if (sortBy != null) {
      switch (sortBy) {
        case 'recent':
          filtered.sort((a, b) => b.deadline.compareTo(a.deadline));
          break;
        case 'popular':
          filtered.sort((a, b) => b.participants.compareTo(a.participants));
          break;
        case 'deadline':
          filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
          break;
        case 'prize':
          filtered.sort((a, b) => b.totalPrize.compareTo(a.totalPrize));
          break;
      }
    }

    return filtered;
  }

  static Competition? getCompetitionById(int id) {
    try {
      return _competitions.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<CompetitionQuestion> getQuestions(int competitionId) {
    return List<CompetitionQuestion>.from(_questions);
  }

  static void submitCompetition(int competitionId, Map<int, int> answers) {
    final competition = getCompetitionById(competitionId);
    if (competition == null) return;

    final questions = getQuestions(competitionId);
    int correctCount = 0;
    for (var entry in answers.entries) {
      final questionIndex = entry.key;
      if (questionIndex < questions.length) {
        final question = questions[questionIndex];
        if (question.correctAnswer == entry.value) {
          correctCount++;
        }
      }
    }

    final score = questions.isEmpty ? 0 : ((correctCount / questions.length) * 100).round();
    final rank = _calculateRank(score);
    final isWinner = score >= 80 && rank <= 3; // Winner if score >= 80% and top 3
    final prizeAmount = isWinner ? (competition.totalPrize ~/ 3) : null; // Top 3 share prize
    
    final result = CompetitionResult(
      competitionId: competitionId,
      competitionTitle: competition.title,
      totalQuestions: questions.length,
      correctAnswers: correctCount,
      score: score,
      rank: rank,
      isWinner: isWinner,
      prizeAmount: prizeAmount,
      submittedAt: DateTime.now(),
      evaluationStatus: 'evaluating',
    );

    _results.add(result);

    // Update competition submission
    final index = _competitions.indexWhere((c) => c.id == competitionId);
    if (index != -1) {
      _competitions[index] = Competition(
        id: _competitions[index].id,
        title: _competitions[index].title,
        description: _competitions[index].description,
        category: _competitions[index].category,
        difficulty: _competitions[index].difficulty,
        timeLimit: _competitions[index].timeLimit,
        entryFee: _competitions[index].entryFee,
        totalPrize: _competitions[index].totalPrize,
        participants: _competitions[index].participants + 1,
        deadline: _competitions[index].deadline,
        status: _competitions[index].status,
        tags: _competitions[index].tags,
        image: _competitions[index].image,
        mySubmission: CompetitionSubmission(
          submitted: true,
          score: score,
          rank: null,
          feedback: null,
          submittedAt: DateTime.now(),
        ),
        stats: _competitions[index].stats,
      );
    }
  }

  static CompetitionResult? getResult(int competitionId) {
    try {
      return _results.firstWhere((r) => r.competitionId == competitionId);
    } catch (e) {
      return null;
    }
  }

  static void updateResultStatus(int competitionId, String status, {bool? isWinner, int? prizeAmount, int? rank}) {
    final index = _results.indexWhere((r) => r.competitionId == competitionId);
    if (index != -1) {
      final oldResult = _results[index];
      _results[index] = CompetitionResult(
        competitionId: oldResult.competitionId,
        competitionTitle: oldResult.competitionTitle,
        totalQuestions: oldResult.totalQuestions,
        correctAnswers: oldResult.correctAnswers,
        score: oldResult.score,
        rank: rank ?? oldResult.rank,
        isWinner: isWinner ?? oldResult.isWinner,
        prizeAmount: prizeAmount ?? oldResult.prizeAmount,
        submittedAt: oldResult.submittedAt,
        evaluatedAt: DateTime.now(),
        evaluationStatus: status,
      );
    }
  }

  static void claimPrize(int competitionId, PrizeClaimInfo info) {
    // In real app, this would send to backend
    final result = getResult(competitionId);
    if (result != null) {
      updateResultStatus(competitionId, 'pending_approval');
    }
  }

  static String getCategoryName(String category) {
    switch (category) {
      case 'speaking':
        return 'Nói';
      case 'writing':
        return 'Viết';
      case 'listening':
        return 'Nghe';
      case 'reading':
        return 'Đọc';
      default:
        return 'Tất cả';
    }
  }

  static int _calculateRank(int score) {
    // Simple rank calculation based on score
    if (score >= 90) return 1;
    if (score >= 80) return 2;
    if (score >= 70) return 3;
    if (score >= 60) return 4;
    return 5;
  }

  // Simulate evaluation completion after delay
  static void completeEvaluation(int competitionId) {
    final index = _results.indexWhere((r) => r.competitionId == competitionId);
    if (index != -1) {
      final oldResult = _results[index];
      _results[index] = CompetitionResult(
        competitionId: oldResult.competitionId,
        competitionTitle: oldResult.competitionTitle,
        totalQuestions: oldResult.totalQuestions,
        correctAnswers: oldResult.correctAnswers,
        score: oldResult.score,
        rank: oldResult.rank,
        isWinner: oldResult.isWinner,
        prizeAmount: oldResult.prizeAmount,
        submittedAt: oldResult.submittedAt,
        evaluatedAt: DateTime.now(),
        evaluationStatus: 'completed',
      );
    }
  }

  static List<CompetitionResult> getLeaderboard(int competitionId) {
    return _results
        .where((r) => r.competitionId == competitionId && r.evaluationStatus == 'completed')
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }
}

