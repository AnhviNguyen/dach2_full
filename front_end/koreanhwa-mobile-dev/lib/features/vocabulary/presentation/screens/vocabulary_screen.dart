import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/match_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/quiz_screen.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/services/vocabulary_service.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/flashcard_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/pronunciation_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/listen_write_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/vocab_test_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/widgets/vocabulary_info_card.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/widgets/learning_mode_button.dart';
import 'package:koreanhwa_flutter/features/vocabulary/data/models/learning_mode.dart';

class VocabularyScreen extends StatefulWidget {
  final int bookId;
  final int lessonId;

  const VocabularyScreen({
    super.key,
    required this.bookId,
    required this.lessonId,
  });

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  List<Map<String, String>> get vocabList {
    return VocabularyService.getVocabularyList(widget.bookId, widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
        ),
        title: Text(
          'Giáo Trình ${widget.bookId} - Bài ${widget.lessonId}',
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildListMode(),
    );
  }

  Widget _buildListMode() {
    final learningModes = [
      LearningMode(
        id: 'flashcard',
        name: 'Flashcard',
        icon: Icons.book,
        color: const Color(0xFF2196F3),
      ),
      LearningMode(
        id: 'match',
        name: 'Ghép từ',
        icon: Icons.compare_arrows,
        color: const Color(0xFF4CAF50),
      ),
      LearningMode(
        id: 'pronunciation',
        name: 'Phát âm',
        icon: Icons.record_voice_over,
        color: const Color(0xFF9C27B0),
      ),
      LearningMode(
        id: 'quiz',
        name: 'Trắc nghiệm',
        icon: Icons.quiz,
        color: const Color(0xFFFF9800),
      ),
      LearningMode(
        id: 'listen_write',
        name: 'Nghe - Viết',
        icon: Icons.hearing,
        color: const Color(0xFFE91E63),
      ),
      LearningMode(
        id: 'test',
        name: 'Kiểm tra',
        icon: Icons.assignment,
        color: const Color(0xFFF44336),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VocabularyInfoCard(totalWords: vocabList.length),
          const SizedBox(height: 24),
          const Text(
            'Chọn phương thức học',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: learningModes.map((mode) {
              return LearningModeButton(
                mode: mode,
                onTap: () {
                  switch (mode.id) {
                    case 'flashcard':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardScreen(
                            bookId: widget.bookId,
                            lessonId: widget.lessonId,
                            vocabList: vocabList,
                          ),
                        ),
                      );
                      break;
                    case 'match':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchScreen(
                            bookId: widget.bookId,
                            lessonId: widget.lessonId,
                            vocabList: vocabList,
                          ),
                        ),
                      );
                      break;
                    case 'pronunciation':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PronunciationScreen(
                            bookId: widget.bookId,
                            lessonId: widget.lessonId,
                            vocabList: vocabList,
                          ),
                        ),
                      );
                      break;
                    case 'quiz':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            bookId: widget.bookId,
                            lessonId: widget.lessonId,
                            vocabList: vocabList,
                          ),
                        ),
                      );
                      break;
                    case 'listen_write':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListenWriteScreen(
                            bookId: widget.bookId,
                            lessonId: widget.lessonId,
                            vocabList: vocabList,
                          ),
                        ),
                      );
                      break;
                    case 'test':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VocabTestScreen(
                            bookId: widget.bookId,
                            lessonId: widget.lessonId,
                            vocabList: vocabList,
                          ),
                        ),
                      );
                      break;
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

