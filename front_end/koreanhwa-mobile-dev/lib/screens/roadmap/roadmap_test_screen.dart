import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/screens/roadmap/roadmap_detail_screen.dart';
import 'dart:async';

class RoadmapTestScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const RoadmapTestScreen({super.key, this.extra});

  @override
  State<RoadmapTestScreen> createState() => _RoadmapTestScreenState();
}

class _RoadmapTestScreenState extends State<RoadmapTestScreen> {
  Map<int, String> _selectedAnswers = {};
  int _timeLeft = 8 * 60; // 8 minutes
  Timer? _timer;
  bool _showQuestionList = false;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'question': "한국어에서 '안녕하세요'의 의미는 무엇입니까? 다음 중 올바른 답을 선택하세요.",
      'options': [
        {'value': 'A', 'text': '좋은 아침입니다'},
        {'value': 'B', 'text': '안녕히 가세요'},
        {'value': 'C', 'text': '반갑습니다'},
        {'value': 'D', 'text': '감사합니다'}
      ]
    },
    {
      'id': 2,
      'question': "다음 문장에서 빈칸에 들어갈 가장 적절한 단어를 고르세요: '저는 한국 음식을 _____ 좋아해요.'",
      'options': [
        {'value': 'A', 'text': '매우'},
        {'value': 'B', 'text': '조금'},
        {'value': 'C', 'text': '전혀'},
        {'value': 'D', 'text': '가끔'}
      ]
    },
  ];

  final List<int> _questionNumbers = List.generate(8, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (var question in _questions) {
      _questionKeys[question['id'] as int] = GlobalKey();
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

  void _submitTest() {
    _timer?.cancel();
    // Calculate score and level
    final score = (_selectedAnswers.length / _questions.length * 100).round();
    int level = 1;
    if (score >= 90) level = 4;
    else if (score >= 70) level = 3;
    else if (score >= 50) level = 2;
    
    RoadmapService.savePlacementResult(level, score);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RoadmapDetailScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              ...(question['options'] as List).map((option) {
                                final value = option['value'] as String;
                                final text = option['text'] as String;
                                final isSelected = selectedAnswer == value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: InkWell(
                                    onTap: () =>
                                        _handleAnswerSelect(questionId, value),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryYellow
                                                .withOpacity(0.2)
                                            : AppColors.primaryWhite,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryYellow
                                              : AppColors.primaryBlack
                                                  .withOpacity(0.2),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
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
                                              color:
                                              AppColors.primaryBlack,
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
                                                color: AppColors.primaryBlack,
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
                            itemCount: _questionNumbers.length,
                            itemBuilder: (context, index) {
                              final num = _questionNumbers[index];
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
                  onPressed: _submitTest,
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

