import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class ListenWriteScreen extends StatefulWidget {
  final int bookId;
  final int lessonId;
  final List<Map<String, String>> vocabList;

  const ListenWriteScreen({
    super.key,
    required this.bookId,
    required this.lessonId,
    required this.vocabList,
  });

  @override
  State<ListenWriteScreen> createState() => _ListenWriteScreenState();
}

class _ListenWriteScreenState extends State<ListenWriteScreen> {
  int _currentWord = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _showResult = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _playAudio() {
    // TODO: Implement text-to-speech
  }

  void _checkAnswer() {
    setState(() {
      _showResult = true;
    });
  }

  void _nextWord() {
    setState(() {
      _currentWord = (_currentWord + 1) % widget.vocabList.length;
      _answerController.clear();
      _showResult = false;
    });
  }

  bool get _isCorrect {
    final vocab = widget.vocabList[_currentWord];
    return _answerController.text.trim().toLowerCase() ==
        vocab['korean']!.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final vocab = widget.vocabList[_currentWord];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryWhite),
        ),
        title: const Text(
          'Listen & Write',
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
                '${_currentWord + 1} / ${widget.vocabList.length}',
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
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primaryWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFF9800),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: _playAudio,
                      iconSize: 64,
                      icon: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          color: AppColors.primaryWhite,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nghe và viết từ tiếng Hàn',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryBlack.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vocab['vietnamese']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _answerController,
                      enabled: !_showResult,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập từ tiếng Hàn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF9800),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF9800),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF9800),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (_showResult) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isCorrect
                              ? AppColors.success.withOpacity(0.2)
                              : const Color(0xFFF44336).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCorrect
                                ? AppColors.success
                                : const Color(0xFFF44336),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _isCorrect ? '✓ Chính xác!' : '✗ Sai rồi!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect
                                    ? AppColors.success
                                    : const Color(0xFFF44336),
                              ),
                            ),
                            if (!_isCorrect) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Đáp án đúng: ${vocab['korean']!}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (!_showResult)
                      ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: AppColors.primaryWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Kiểm tra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: _nextWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryBlack,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tiếp theo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
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

