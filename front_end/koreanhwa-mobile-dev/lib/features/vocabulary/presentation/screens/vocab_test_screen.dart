import 'dart:math';
import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class VocabTestScreen extends StatefulWidget {
  final int bookId;
  final int lessonId;
  final List<Map<String, String>> vocabList;

  const VocabTestScreen({
    super.key,
    required this.bookId,
    required this.lessonId,
    required this.vocabList,
  });

  @override
  State<VocabTestScreen> createState() => _VocabTestScreenState();
}

class _VocabTestScreenState extends State<VocabTestScreen> {
  int _currentQuestion = 0;
  Map<int, String> _answers = {};
  bool _showResults = false;
  final Random _random = Random();

  List<String> _getOptionsForQuestion(int index) {
    final correct = widget.vocabList[index]['vietnamese']!;
    final others = widget.vocabList
        .where((v) => v != widget.vocabList[index])
        .toList()
      ..shuffle(_random);
    final otherOptions = others.take(3).map((v) => v['vietnamese']!).toList();
    return [...otherOptions, correct]..shuffle(_random);
  }

  void _handleAnswer(String answer) {
    setState(() {
      _answers[_currentQuestion] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.vocabList.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    }
  }

  void _prevQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  void _submitTest() {
    setState(() {
      _showResults = true;
    });
  }

  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < widget.vocabList.length; i++) {
      if (_answers[i] == widget.vocabList[i]['vietnamese']) {
        correct++;
      }
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      final score = _calculateScore();
      final percentage = (score / widget.vocabList.length * 100).round();

      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFCE4EC),
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFE91E63),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.primaryWhite),
          ),
          title: Text(
            'Kết quả Test',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.primaryWhite,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.cardColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : const Color(0xFFE91E63),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 80
                        ? AppColors.success
                        : percentage >= 60
                            ? AppColors.primaryYellow
                            : const Color(0xFFF44336),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$score / ${widget.vocabList.length}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'câu đúng',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryBlack.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  percentage >= 80
                      ? '🎉 Xuất sắc!'
                      : percentage >= 60
                          ? '👍 Khá tốt!'
                          : '💪 Cố gắng thêm nhé!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 80
                        ? AppColors.success
                        : percentage >= 60
                            ? AppColors.primaryYellow
                            : const Color(0xFFF44336),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showResults = false;
                            _currentQuestion = 0;
                            _answers.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: AppColors.primaryWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Làm lại',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlack,
                          foregroundColor: AppColors.primaryWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Quay lại',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final vocab = widget.vocabList[_currentQuestion];
    final options = _getOptionsForQuestion(_currentQuestion);
    final selectedAnswer = _answers[_currentQuestion];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFE91E63),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.primaryWhite),
        ),
        title: Text(
          'Test',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryWhite,
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
                '${_currentQuestion + 1} / ${widget.vocabList.length}',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primaryWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE91E63),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    vocab['korean']!,
                    style: const TextStyle(
                      fontSize: 36,
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ...options.map((option) {
                    final isSelected = selectedAnswer == option;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _handleAnswer(option),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE91E63)
                                : AppColors.primaryBlack.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE91E63)
                                  : AppColors.primaryBlack.withOpacity(0.1),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primaryWhite
                                  : AppColors.primaryBlack,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _prevQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlack,
                      foregroundColor: AppColors.primaryWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Trước',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestion == widget.vocabList.length - 1
                        ? null
                        : _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sau',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_currentQuestion == widget.vocabList.length - 1) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: AppColors.primaryWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Nộp bài',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(widget.vocabList.length, (index) {
                final hasAnswer = _answers[index] != null;
                final isCurrent = _currentQuestion == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentQuestion = index;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: hasAnswer
                          ? const Color(0xFFE91E63)
                          : isCurrent
                              ? AppColors.primaryYellow
                              : AppColors.primaryBlack.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: hasAnswer
                              ? AppColors.primaryWhite
                              : isCurrent
                                  ? AppColors.primaryBlack
                                  : AppColors.primaryBlack.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

