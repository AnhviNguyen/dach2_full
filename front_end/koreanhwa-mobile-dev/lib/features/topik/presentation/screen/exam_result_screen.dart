import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screen/topik_test_form_screen.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:koreanhwa_flutter/features/topik/data/services/exam_result_service.dart';
import 'package:koreanhwa_flutter/features/topik/data/services/topik_api_service.dart';

class ExamResultScreen extends StatefulWidget {
  final String examId;
  final String examTitle;
  final Map<int, String> answers;
  final List<Map<String, dynamic>> questions;
  final int timeSpent; // Thời gian đã làm bài (tính bằng giây)

  const ExamResultScreen({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.answers,
    required this.questions,
    this.timeSpent = 0,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TopikApiService _apiService = TopikApiService();
  bool _isLoadingExplanation = false;
  final List<Map<String, dynamic>> _comments = [
    {
      'id': 1,
      'user': 'Nguyễn Minh',
      'avatar': 'NM',
      'content': 'Mình thấy phần ngữ pháp về thì khá khó, có ai có tips không?',
      'time': '2 giờ trước',
    },
    {
      'id': 2,
      'user': 'Lê Thu Hà',
      'avatar': 'LH',
      'content': 'Cảm ơn bài test này, giúp mình nhận ra điểm yếu về danh từ. Sẽ ôn lại phần này!',
      'time': '3 giờ trước',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Lưu kết quả sau khi widget đã được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveExamResult();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Lưu kết quả bài thi
  Future<void> _saveExamResult() async {
    try {
      // Tính toán kết quả
      final correctCount = _correctCount;
      final wrongCount = _wrongCount;
      final skippedCount = _skippedCount;
      final accuracy = _accuracy;
      
      final result = ExamResult(
        examId: widget.examId,
        examTitle: widget.examTitle,
        answers: widget.answers,
        questions: widget.questions,
        timeSpent: widget.timeSpent,
        correctCount: correctCount,
        wrongCount: wrongCount,
        skippedCount: skippedCount,
        accuracy: accuracy,
        completedAt: DateTime.now(),
      );
      await ExamResultService.saveExamResult(result);
    } catch (e) {
      debugPrint('Error saving exam result: $e');
    }
  }

  // Tính toán kết quả thực tế dựa trên answers và questions
  String _getCorrectAnswer(int questionId) {
    // Tìm câu hỏi trong danh sách
    final question = widget.questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    
    // Lấy correct_answer từ question (đã được lưu từ API)
    final correctAnswer = question['correct_answer'] as String?;
    if (correctAnswer != null && correctAnswer.isNotEmpty) {
      return correctAnswer;
    }
    
    // Nếu không có correct_answer (TOPIK 1 hoặc chưa có data), trả về empty string
    // Frontend sẽ hiển thị "-" hoặc không hiển thị đáp án đúng
    return '';
  }
  
  // Lấy thông tin exam từ examId hoặc questions
  String _getExamNumber() {
    // Parse từ examId (ví dụ: "TK35" -> "35")
    if (widget.examId.startsWith('TK')) {
      return widget.examId.replaceAll('TK', '');
    }
    // Hoặc lấy từ question đầu tiên nếu có
    if (widget.questions.isNotEmpty) {
      final examNumber = widget.questions.first['exam_number'] as String?;
      if (examNumber != null && examNumber.isNotEmpty) {
        return examNumber;
      }
    }
    // Fallback: lấy từ examId trực tiếp
    return widget.examId;
  }
  
  String _getTopikLevel() {
    // Lấy từ question đầu tiên nếu có
    if (widget.questions.isNotEmpty) {
      final topikLevel = widget.questions.first['topik_level'] as String?;
      if (topikLevel != null && (topikLevel == '1' || topikLevel == '2')) {
        return topikLevel;
      }
    }
    // Fallback: mặc định là TOPIK 1
    return '1';
  }
  
  String _getQuestionType() {
    // Lấy từ question đầu tiên nếu có
    if (widget.questions.isNotEmpty) {
      final questionType = widget.questions.first['question_type'] as String?;
      if (questionType != null && (questionType == 'listening' || questionType == 'reading')) {
        return questionType;
      }
    }
    // Fallback: mặc định là reading
    return 'reading';
  }

  bool _isCorrect(int questionId, String? userAnswer) {
    if (userAnswer == null) return false;
    return userAnswer == _getCorrectAnswer(questionId);
  }

  int get _correctCount {
    int count = 0;
    for (var question in widget.questions) {
      final questionId = question['id'] as int;
      final userAnswer = widget.answers[questionId];
      if (userAnswer != null && _isCorrect(questionId, userAnswer)) {
        count++;
      }
    }
    return count;
  }

  int get _wrongCount {
    int count = 0;
    for (var question in widget.questions) {
      final questionId = question['id'] as int;
      final userAnswer = widget.answers[questionId];
      if (userAnswer != null && !_isCorrect(questionId, userAnswer)) {
        count++;
      }
    }
    return count;
  }

  int get _skippedCount {
    int count = 0;
    for (var question in widget.questions) {
      final questionId = question['id'] as int;
      if (widget.answers[questionId] == null) {
        count++;
      }
    }
    return count;
  }

  int get _totalQuestions => widget.questions.length;

  double get _accuracy {
    final total = _totalQuestions;
    return total > 0 ? _correctCount / total : 0.0;
  }

  // Tính toán phân tích chi tiết theo category (mock data tạm thời)
  // Vì chưa có thông tin category từ API, chia questions thành các nhóm
  List<Map<String, dynamic>> get _testData {
    if (widget.questions.isEmpty) return [];
    
    // Chia questions thành 3 nhóm để hiển thị phân tích
    final total = widget.questions.length;
    final groupSize = (total / 3).ceil();
    
    List<Map<String, dynamic>> result = [];
    
    for (int i = 0; i < 3 && i * groupSize < total; i++) {
      final start = i * groupSize;
      final end = (start + groupSize < total) ? start + groupSize : total;
      final groupQuestions = widget.questions.sublist(start, end);
      
      int correct = 0;
      int wrong = 0;
      int skipped = 0;
      List<int> questionIds = [];
      
      for (var question in groupQuestions) {
        final questionId = question['id'] as int;
        questionIds.add(questionId);
        final userAnswer = widget.answers[questionId];
        
        if (userAnswer == null) {
          skipped++;
        } else if (_isCorrect(questionId, userAnswer)) {
          correct++;
        } else {
          wrong++;
        }
      }
      
      final totalInGroup = correct + wrong + skipped;
      final accuracy = totalInGroup > 0 
          ? ((correct / totalInGroup) * 100).toStringAsFixed(2)
          : '0.00';
      
      result.add({
        'category': i == 0 ? '[문법] Giới từ' : (i == 1 ? '[문법] Thì' : '[문법] Danh từ'),
        'correct': correct,
        'wrong': wrong,
        'skipped': skipped,
        'accuracy': '$accuracy%',
        'questions': questionIds,
      });
    }
    
    return result;
  }

  // Format thời gian đã làm bài
  String _formatTimeSpent(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _handleAddComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      _comments.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'user': 'Bạn',
        'avatar': 'B',
        'content': _commentController.text.trim(),
        'time': 'Vừa xong',
      });
      _commentController.clear();
    });
  }

  // Hiển thị bottom sheet giải thích câu hỏi
  Future<void> _showQuestionExplanation(int questionId) async {
    // Tìm câu hỏi trong danh sách
    final question = widget.questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy câu hỏi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Lấy thông tin cần thiết
    final questionIdStr = question['question_id'] as String? ?? '';
    final questionNumber = question['number'] as int? ?? questionId;
    
    if (questionIdStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Câu hỏi này không có ID để giải thích'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoadingExplanation = true;
    });
    
    try {
      final examNumber = _getExamNumber();
      final topikLevel = _getTopikLevel();
      final questionType = _getQuestionType();
      
      // Gọi API giải thích
      final response = await _apiService.explainTopikQuestion(
        examNumber: examNumber,
        questionId: questionIdStr,
        topikLevel: topikLevel,
        questionType: questionType,
      );
      
      final explanation = response['explanation'] as String? ?? 'Không có giải thích';
      final questionData = response['question'] as Map<String, dynamic>? ?? {};
      final correctAnswer = response['correct_answer'] as String?;
      
      if (!mounted) return;
      
      setState(() {
        _isLoadingExplanation = false;
      });
      
      // Hiển thị bottom sheet
      _showExplanationBottomSheet(
        questionNumber: questionNumber,
        question: questionData,
        explanation: explanation,
        correctAnswer: correctAnswer,
        userAnswer: widget.answers[questionId],
        isCorrect: _isCorrect(questionId, widget.answers[questionId]),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingExplanation = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải giải thích: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Bottom sheet hiển thị giải thích
  void _showExplanationBottomSheet({
    required int questionNumber,
    required Map<String, dynamic> question,
    required String explanation,
    String? correctAnswer,
    String? userAnswer,
    required bool isCorrect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primaryBlack.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Giải thích câu $questionNumber',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.primaryBlack),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kết quả
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppColors.success.withOpacity(0.1)
                            : const Color(0xFFF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCorrect ? AppColors.success : const Color(0xFFF44336),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? AppColors.success : const Color(0xFFF44336),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isCorrect
                                  ? 'Bạn đã trả lời đúng'
                                  : 'Bạn đã trả lời sai',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isCorrect ? AppColors.success : const Color(0xFFF44336),
                              ),
                            ),
                          ),
                          if (userAnswer != null)
                            Text(
                              'Đáp án của bạn: $userAnswer',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlack.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (correctAnswer != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryYellow,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.primaryYellow,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đáp án đúng: $correctAnswer',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Câu hỏi
                    const SizedBox(height: 16),
                    const Text(
                      'Câu hỏi:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlack.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        question['prompt'] as String? ?? question['intro_text'] as String? ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBlack.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                    // Các đáp án
                    const SizedBox(height: 16),
                    const Text(
                      'Các đáp án:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(question['answers'] as List<dynamic>? ?? []).asMap().entries.map((entry) {
                      final index = entry.key;
                      final answer = entry.value as Map<String, dynamic>;
                      final option = answer['option'] as String? ?? String.fromCharCode(65 + index);
                      final text = answer['text'] as String? ?? '';
                      final isCorrectOption = correctAnswer != null && option == correctAnswer;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCorrectOption
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.primaryBlack.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCorrectOption
                                ? AppColors.success
                                : AppColors.primaryBlack.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isCorrectOption
                                    ? AppColors.success
                                    : AppColors.primaryBlack.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isCorrectOption
                                        ? Colors.white
                                        : AppColors.primaryBlack,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryBlack.withOpacity(0.8),
                                ),
                              ),
                            ),
                            if (isCorrectOption)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                          ],
                        ),
                      );
                    }),
                    // Giải thích
                    const SizedBox(height: 16),
                    const Text(
                      'Giải thích:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryYellow.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        explanation,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBlack.withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
        ),
        title: Text(
          'Kết quả luyện tập',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.examTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Part 5',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Scroll to answer key
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlack,
                            foregroundColor: AppColors.primaryWhite,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Xem đáp án',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).cardColor,
                            foregroundColor: AppColors.primaryBlack,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: AppColors.primaryBlack.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Quay lại',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Main Stats Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.primaryYellow,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_correctCount/$_totalQuestions',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Độ chính xác: ${(_accuracy * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryBlack.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          Icons.check_circle,
                          'Đúng',
                          _correctCount.toString(),
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          Icons.cancel,
                          'Sai',
                          _wrongCount.toString(),
                          const Color(0xFFF44336),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          Icons.remove_circle_outline,
                          'Bỏ qua',
                          _skippedCount.toString(),
                          AppColors.primaryBlack.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: AppColors.primaryBlack,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thời gian: ${_formatTimeSpent(widget.timeSpent)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phân bố kết quả',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: _correctCount.toDouble(),
                            color: AppColors.success,
                            title: 'Đúng\n$_correctCount',
                            radius: 60,
                            titleStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          PieChartSectionData(
                            value: _wrongCount.toDouble(),
                            color: const Color(0xFFF44336),
                            title: 'Sai\n$_wrongCount',
                            radius: 60,
                            titleStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Analysis Table (Mobile Friendly)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack.withOpacity(0.05),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Phân tích chi tiết',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                  ..._testData.map((row) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.primaryBlack.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row['category'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildMiniStat('Đúng', row['correct'].toString(), AppColors.success),
                              const SizedBox(width: 8),
                              _buildMiniStat('Sai', row['wrong'].toString(), const Color(0xFFF44336)),
                              const SizedBox(width: 8),
                              _buildMiniStat('Bỏ qua', row['skipped'].toString(), AppColors.primaryBlack.withOpacity(0.4)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Độ chính xác: ${row['accuracy']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (row['questions'] as List<int>).map((q) {
                              final isWrong = row['wrong'] as int > 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isWrong
                                      ? const Color(0xFFF44336).withOpacity(0.2)
                                      : AppColors.success.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isWrong
                                        ? const Color(0xFFF44336)
                                        : AppColors.success,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  q.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isWrong
                                        ? const Color(0xFFF44336)
                                        : AppColors.success,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Answer Key Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đáp án',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlack,
                        foregroundColor: AppColors.primaryWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xem chi tiết đáp án',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopikTestFormScreen(
                              examId: widget.examId,
                              examTitle: widget.examTitle,
                              isFullTest: false,
                              selectedSections: {'listening': true, 'reading': true},
                              timeLimit: '',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlack,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Làm lại các câu sai',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.success,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tips: Xem chi tiết đáp án để tạo highlight từ vựng, keywords và note học tập.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Part 5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.questions.map((question) {
                      final questionId = question['id'] as int;
                      final userAnswer = widget.answers[questionId];
                      final correctAnswer = _getCorrectAnswer(questionId);
                      final isCorrect = userAnswer != null && _isCorrect(questionId, userAnswer);
                      return GestureDetector(
                        onTap: () => _showQuestionExplanation(questionId),
                        child: _buildQuestionItem(
                          questionId,
                          userAnswer ?? '-',
                          correctAnswer,
                          isCorrect,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Comments Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        color: AppColors.primaryBlack,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bình luận (${_comments.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Chia sẻ nhận xét của bạn...',
                      hintStyle: TextStyle(fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.primaryBlack.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.primaryBlack.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primaryYellow,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _handleAddComment,
                      icon: const Icon(Icons.send, size: 14),
                      label: const Text(
                        'Gửi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlack,
                        foregroundColor: AppColors.primaryWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._comments.map((comment) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlack.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                comment['avatar'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment['user'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlack,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${comment['time']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primaryBlack.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment['content'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryBlack.withOpacity(0.7),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(
      int questionNumber, String userAnswer, String correctAnswer, bool isCorrect) {
    // Nếu user chưa trả lời (userAnswer == '-'), hiển thị màu xám
    final isSkipped = userAnswer == '-';
    final color = isSkipped 
        ? AppColors.primaryBlack.withOpacity(0.4)
        : (isCorrect ? AppColors.success : const Color(0xFFF44336));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$questionNumber',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          if (!isSkipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                userAnswer,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).cardColor,
                ),
              ),
            ),
          if (isSkipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack.withOpacity(0.6),
                ),
              ),
            ),
          const SizedBox(width: 4),
          if (!isSkipped)
            Icon(
              isCorrect ? Icons.check : Icons.close,
              size: 14,
              color: color,
            ),
          if (isSkipped)
            Icon(
              Icons.remove_circle_outline,
              size: 14,
              color: color,
            ),
          const SizedBox(width: 4),
          if (correctAnswer.isNotEmpty)
            Text(
              correctAnswer,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            )
          else
            Text(
              'N/A',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(width: 4),
          Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.primaryBlack.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}