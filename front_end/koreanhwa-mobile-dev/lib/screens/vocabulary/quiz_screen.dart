import 'dart:math';
import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  final int bookId;
  final int lessonId;
  final List<Map<String, String>> vocabList;

  const QuizScreen({
    super.key,
    required this.bookId,
    required this.lessonId,
    required this.vocabList,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  String? _selectedAnswer;
  int _score = 0;
  List<String> _options = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateOptions();
  }

  void _generateOptions() {
    final vocab = widget.vocabList[_currentQuestion];
    final correct = vocab['vietnamese']!;
    final others = widget.vocabList
        .where((v) => v != vocab)
        .toList()
      ..shuffle(_random);
    final otherOptions = others.take(3).map((v) => v['vietnamese']!).toList();
    _options = [...otherOptions, correct]..shuffle(_random);
  }

  void _handleAnswer(String answer) {
    final vocab = widget.vocabList[_currentQuestion];
    setState(() {
      _selectedAnswer = answer;
      if (answer == vocab['vietnamese']) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentQuestion < widget.vocabList.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedAnswer = null;
          _generateOptions();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vocab = widget.vocabList[_currentQuestion];
    final showResult = _selectedAnswer != null;
    final isCorrect = _selectedAnswer == vocab['vietnamese'];

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44336),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryWhite),
        ),
        title: const Text(
          'Quiz',
          style: TextStyle(
            color: AppColors.primaryWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Điểm: $_score / ${widget.vocabList.length}',
                style: const TextStyle(
                  color: AppColors.primaryWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFF44336),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF44336).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Câu ${_currentQuestion + 1} / ${widget.vocabList.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlack.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      vocab['korean']!,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vocab['pronunciation']!,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.primaryBlack.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._options.map((option) {
                      final isSelected = _selectedAnswer == option;
                      final isCorrectOption = option == vocab['vietnamese'];

                      Color bgColor = AppColors.primaryBlack.withOpacity(0.05);
                      Color textColor = AppColors.primaryBlack;
                      if (showResult) {
                        if (isCorrectOption) {
                          bgColor = AppColors.success;
                          textColor = AppColors.primaryWhite;
                        } else if (isSelected && !isCorrectOption) {
                          bgColor = const Color(0xFFF44336);
                          textColor = AppColors.primaryWhite;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: _selectedAnswer == null
                              ? () => _handleAnswer(option)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: showResult && isCorrectOption
                                    ? AppColors.success
                                    : showResult && isSelected && !isCorrectOption
                                        ? const Color(0xFFF44336)
                                        : AppColors.primaryBlack.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

