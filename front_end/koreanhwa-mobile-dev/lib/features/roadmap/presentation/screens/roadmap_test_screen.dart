import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/roadmap/presentation/screens/roadmap_detail_screen.dart';
import 'package:koreanhwa_flutter/features/roadmap/data/services/roadmap_api_service.dart';
import 'package:koreanhwa_flutter/core/utils/user_utils.dart';
import 'dart:async';

class RoadmapTestScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const RoadmapTestScreen({super.key, this.extra});

  @override
  State<RoadmapTestScreen> createState() => _RoadmapTestScreenState();
}

class _RoadmapTestScreenState extends State<RoadmapTestScreen> {
  final RoadmapApiService _apiService = RoadmapApiService();
  Map<int, String> _selectedAnswers = {};
  int _timeLeft = 8 * 60; // 8 minutes
  Timer? _timer;
  bool _showQuestionList = false;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};
  
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _originalQuestions = []; // Store original questions from API
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }
  
  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _apiService.getPlacementQuestions(count: 8);
      final questions = (response['questions'] as List<dynamic>)
          .map((q) => q as Map<String, dynamic>)
          .toList();
      
      // Store original questions
      _originalQuestions = questions;
      
      // Transform questions to match UI format
      _questions = questions.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value;
        
        // Extract options (GPT format)
        final options = (q['options'] as List<dynamic>?) ?? [];
        final optionsList = options.map((a) {
          return {
            'value': a['value'] ?? '',
            'text': a['text'] ?? '',
          };
        }).toList();
        
        // Get question text
        final questionText = q['question'] ?? '';
        
        return {
          'id': index + 1,
          'question_id': q['id'] ?? 'q${index + 1}',
          'question': questionText,
          'options': optionsList,
          'correct_answer': q['correct_answer'] ?? '',
          'difficulty': q['difficulty'] ?? '1',
          'type': q['type'] ?? 'general',
        };
      }).toList();
      
      // Create keys for questions
      for (var question in _questions) {
        _questionKeys[question['id'] as int] = GlobalKey();
      }
      
      _startTimer();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi tải câu hỏi: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        timer.cancel();
        _submitTest();
        return;
      }
      setState(() {
        _timeLeft--;
      });
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _handleAnswerSelect(int questionId, String answer) {
    setState(() {
      _selectedAnswers[questionId] = answer;
    });
  }
  
  bool _isAnswerCorrect(int questionId, String? selectedAnswer) {
    if (selectedAnswer == null) return false;
    final question = _questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    final correctAnswer = question['correct_answer'] as String? ?? '';
    return selectedAnswer == correctAnswer;
  }
  
  Color _getOptionColor(int questionId, String optionValue, String? selectedAnswer) {
    if (selectedAnswer == null) return Colors.transparent;
    
    final question = _questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    final correctAnswer = question['correct_answer'] as String? ?? '';
    
    // If this is the correct answer, show green
    if (optionValue == correctAnswer) {
      return AppColors.success.withOpacity(0.2);
    }
    // If this is selected but wrong, show red
    if (optionValue == selectedAnswer && optionValue != correctAnswer) {
      return AppColors.error.withOpacity(0.2);
    }
    return Colors.transparent;
  }
  
  Color _getOptionBorderColor(int questionId, String optionValue, String? selectedAnswer) {
    if (selectedAnswer == null) {
      return AppColors.primaryBlack.withOpacity(0.2);
    }
    
    final question = _questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    final correctAnswer = question['correct_answer'] as String? ?? '';
    
    // If this is the correct answer, show green border
    if (optionValue == correctAnswer) {
      return AppColors.success;
    }
    // If this is selected but wrong, show red border
    if (optionValue == selectedAnswer && optionValue != correctAnswer) {
      return AppColors.error;
    }
    // If selected but not this option
    if (selectedAnswer == optionValue) {
      return AppColors.primaryYellow;
    }
    return AppColors.primaryBlack.withOpacity(0.2);
  }
  
  Widget? _getOptionIcon(int questionId, String optionValue, String? selectedAnswer) {
    if (selectedAnswer == null) return null;
    
    final question = _questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    final correctAnswer = question['correct_answer'] as String? ?? '';
    
    // Show check icon for correct answer
    if (optionValue == correctAnswer) {
      return const Icon(
        Icons.check_circle,
        size: 20,
        color: AppColors.success,
      );
    }
    // Show X icon for wrong selected answer
    if (optionValue == selectedAnswer && optionValue != correctAnswer) {
      return const Icon(
        Icons.cancel,
        size: 20,
        color: AppColors.error,
      );
    }
    // Show check for selected correct answer
    if (optionValue == selectedAnswer && optionValue == correctAnswer) {
      return const Icon(
        Icons.check_circle,
        size: 20,
        color: AppColors.success,
      );
    }
    return null;
  }

  void _scrollToQuestion(int questionId) {
    final key = _questionKeys[questionId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
      setState(() {
        _showQuestionList = false;
      });
    }
  }

  Future<void> _submitTest() async {
    _timer?.cancel();
    
    if (_questions.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = await UserUtils.getUserId();
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập để nộp bài')),
          );
        }
        return;
      }
      
      // Prepare answers for submission
      final answers = _questions.map((q) {
        final questionId = q['question_id'] ?? q['id'].toString();
        final userAnswer = _selectedAnswers[q['id'] as int] ?? '';
        final correctAnswer = q['correct_answer'] ?? '';
        final isCorrect = userAnswer == correctAnswer;
        
        return {
          'question_id': questionId,
          'question': q['question'] ?? '',
          'user_answer': userAnswer,
          'correct_answer': correctAnswer,
          'is_correct': isCorrect,
          'difficulty': q['difficulty'] ?? '1',
          'type': q['type'] ?? 'general',
        };
      }).toList();
      
      // Get survey data from extra
      final surveyData = widget.extra?['surveyData'] ?? {};
      
      // Submit to API with original questions
      final result = await _apiService.submitPlacementTest(
        userId: userId,
        surveyData: surveyData,
        answers: answers,
        questions: _originalQuestions,
      );
      
      // Save result
      final level = result['level'] as int? ?? 1;
      final score = (result['score'] as num?)?.toDouble() ?? 0.0;
      final textbookUnlock = result['textbook_unlock'] as int? ?? 0;
      await RoadmapService.savePlacementResult(level, score.round());
      await RoadmapService.setUserLevel(level, textbookUnlock);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RoadmapDetailScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi nộp bài: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi nộp bài: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFDE7),
        appBar: AppBar(
          backgroundColor: AppColors.primaryWhite,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Bài kiểm tra đầu vào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_errorMessage != null && _questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFDE7),
        appBar: AppBar(
          backgroundColor: AppColors.primaryWhite,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Bài kiểm tra đầu vào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bài kiểm tra đầu vào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            Text(
              'Roadmap Test',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryBlack,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF44336).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF44336),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Color(0xFFF44336),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_timeLeft),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF44336),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryYellow.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._questions.map((question) {
                        final questionId = question['id'] as int;
                        final selectedAnswer = _selectedAnswers[questionId];
                        return Container(
                          key: _questionKeys[questionId],
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Câu $questionId',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryWhite,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SelectableText(
                                question['question'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...((question['options'] as List?) ?? []).map((option) {
                                final value = option['value'] as String;
                                final text = option['text'] as String;
                                final isSelected = selectedAnswer == value;
                                final optionColor = _getOptionColor(questionId, value, selectedAnswer);
                                final borderColor = _getOptionBorderColor(questionId, value, selectedAnswer);
                                final optionIcon = _getOptionIcon(questionId, value, selectedAnswer);
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: InkWell(
                                    onTap: () =>
                                        _handleAnswerSelect(questionId, value),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: optionColor != Colors.transparent
                                            ? optionColor
                                            : (isSelected
                                                ? AppColors.primaryYellow.withOpacity(0.2)
                                                : AppColors.primaryWhite),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: borderColor,
                                          width: (isSelected || optionColor != Colors.transparent) ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          if (optionIcon != null)
                                            optionIcon
                                          else
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primaryYellow
                                                      : AppColors.primaryBlack
                                                          .withOpacity(0.3),
                                                  width: 2,
                                                ),
                                                color: isSelected
                                                    ? AppColors.primaryYellow
                                                    : Colors.transparent,
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                Icons.check,
                                                size: 12,
                                                color: AppColors.primaryBlack,
                                              )
                                                  : null,
                                            ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '$value. $text',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: optionColor == AppColors.error.withOpacity(0.2)
                                                    ? AppColors.error
                                                    : (optionColor == AppColors.success.withOpacity(0.2)
                                                        ? AppColors.success
                                                        : AppColors.primaryBlack),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (_showQuestionList)
            GestureDetector(
              onTap: () => setState(() => _showQuestionList = false),
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Danh sách câu hỏi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => _showQuestionList = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _questions.length,
                            itemBuilder: (context, index) {
                              final num = index + 1;
                              final isAnswered = _selectedAnswers[num] != null;
                              final isCurrent = num <= _questions.length;

                              return InkWell(
                                onTap: isCurrent
                                    ? () => _scrollToQuestion(num)
                                    : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? (isAnswered
                                        ? AppColors.success
                                        : AppColors.primaryYellow)
                                        : AppColors.primaryBlack
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.primaryBlack,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      num.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? (isAnswered
                                                ? AppColors.primaryWhite
                                                : AppColors.primaryBlack)
                                            : AppColors.primaryBlack
                                                .withOpacity(0.4),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _showQuestionList = true),
                  icon: const Icon(Icons.list, size: 20),
                  label: Text(
                    'Câu hỏi (${_selectedAnswers.length}/${_questions.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: AppColors.primaryWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'NỘP BÀI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

