import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/services/vocabulary_service.dart';
import 'package:koreanhwa_flutter/screens/vocabulary/flashcard_screen.dart';
import 'package:koreanhwa_flutter/screens/vocabulary/match_screen.dart';
import 'package:koreanhwa_flutter/screens/vocabulary/pronunciation_screen.dart';
import 'package:koreanhwa_flutter/screens/vocabulary/quiz_screen.dart';
import 'package:koreanhwa_flutter/screens/vocabulary/listen_write_screen.dart';
import 'package:koreanhwa_flutter/screens/vocabulary/vocab_test_screen.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow.withOpacity(0.2),
                  AppColors.primaryYellow.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryYellow,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng từ vựng',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vocabList.length}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBlack,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.book,
                    size: 32,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Learning modes
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
            children: [
              _buildModeButton(
                'Flashcard',
                Icons.book,
                const Color(0xFF2196F3),
                () {
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
                },
              ),
              _buildModeButton(
                'Match',
                Icons.shuffle,
                const Color(0xFF9C27B0),
                () {
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
                },
              ),
              _buildModeButton(
                'Pronunciation',
                Icons.volume_up,
                const Color(0xFF4CAF50),
                () {
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
                },
              ),
              _buildModeButton(
                'Quiz',
                Icons.quiz,
                const Color(0xFFF44336),
                () {
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
                },
              ),
              _buildModeButton(
                'Listen & Write',
                Icons.headphones,
                const Color(0xFFFF9800),
                () {
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
                },
              ),
              _buildModeButton(
                'Test',
                Icons.edit,
                const Color(0xFFE91E63),
                () {
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
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Vocabulary list
          const Text(
            'Danh sách từ vựng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),
          ...vocabList.map((vocab) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryBlack.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocab['korean']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vocab['pronunciation']!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryBlack.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vocab['vietnamese']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vocab['example']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryBlack.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.volume_up,
                      color: AppColors.primaryYellow,
                      size: 24,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildModeButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryBlack,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primaryWhite,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
