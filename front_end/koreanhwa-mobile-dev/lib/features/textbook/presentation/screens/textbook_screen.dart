import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/screens/learning_curriculum_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/vocabulary_screen.dart';
import 'package:koreanhwa_flutter/features/textbook/data/models/textbook.dart';
import 'package:koreanhwa_flutter/features/textbook/data/models/lesson_progress.dart';
import 'package:koreanhwa_flutter/features/textbook/data/services/textbook_api_service.dart';
import 'package:koreanhwa_flutter/features/textbook/presentation/widgets/continue_learning_card.dart';
import 'package:koreanhwa_flutter/features/textbook/presentation/widgets/lesson_button.dart';

class TextbookScreen extends StatefulWidget {
  const TextbookScreen({super.key});

  @override
  State<TextbookScreen> createState() => _TextbookScreenState();
}

class _TextbookScreenState extends State<TextbookScreen> {
  int currentBook = 2;
  int currentLesson = 8;
  int? expandedBookId;
  final Map<String, LessonProgress> lessonProgress = {};
  List<Textbook> textbooks = [];
  bool isLoading = true;
  final TextbookApiService _apiService = TextbookApiService();

  @override
  void initState() {
    super.initState();
    _loadTextbooks();
  }

  Future<void> _loadTextbooks() async {
    try {
      final response = await _apiService.getTextbooks(size: 100);
      setState(() {
        textbooks = response.content;
        isLoading = false;
        if (textbooks.isNotEmpty) {
          currentBook = textbooks.firstWhere(
            (t) => !t.isLocked && t.completedLessons < t.totalLessons,
            orElse: () => textbooks.first,
          ).bookNumber;
        }
      });
      
      // Initialize lesson progress
      for (final textbook in textbooks) {
        for (int lesson = 1; lesson <= textbook.totalLessons; lesson++) {
          final key = '${textbook.bookNumber}-$lesson';
          final isUnlocked = !textbook.isLocked && 
              (lesson <= textbook.completedLessons + 1);
          lessonProgress[key] = LessonProgress(
            unlocked: isUnlocked,
            learn: lesson <= textbook.completedLessons,
            vocab: lesson <= textbook.completedLessons,
            grammar: lesson <= textbook.completedLessons,
            chat: false,
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: ${e.toString()}')),
        );
      }
    }
  }

  void toggleBook(int bookId) {
    setState(() {
      expandedBookId = expandedBookId == bookId ? null : bookId;
    });
  }

  void updateLessonProgress(int bookId, int lessonId, String type) {
    setState(() {
      final key = '$bookId-$lessonId';
      final progress = lessonProgress[key];
      if (progress != null) {
        switch (type) {
          case 'learn':
            lessonProgress[key] = LessonProgress(
              unlocked: progress.unlocked,
              learn: !progress.learn,
              vocab: progress.vocab,
              grammar: progress.grammar,
              chat: progress.chat,
            );
            break;
          case 'vocab':
            lessonProgress[key] = LessonProgress(
              unlocked: progress.unlocked,
              learn: progress.learn,
              vocab: !progress.vocab,
              grammar: progress.grammar,
              chat: progress.chat,
            );
            break;
          case 'grammar':
            lessonProgress[key] = LessonProgress(
              unlocked: progress.unlocked,
              learn: progress.learn,
              vocab: progress.vocab,
              grammar: !progress.grammar,
              chat: progress.chat,
            );
            break;
          case 'chat':
            lessonProgress[key] = LessonProgress(
              unlocked: progress.unlocked,
              learn: progress.learn,
              vocab: progress.vocab,
              grammar: progress.grammar,
              chat: !progress.chat,
            );
            break;
        }

        final newProgress = lessonProgress[key]!;
        if (newProgress.learn && newProgress.vocab && newProgress.grammar && newProgress.chat) {
          int nextLesson = lessonId + 1;
          int nextBook = bookId;
          if (nextLesson > 15) {
            nextLesson = 1;
            nextBook = bookId + 1;
          }
          if (nextBook <= 6) {
            final nextKey = '$nextBook-$nextLesson';
            lessonProgress[nextKey] = LessonProgress(
              unlocked: true,
              learn: false,
              vocab: false,
              grammar: false,
              chat: false,
            );
          }
        }
      }
    });
  }

  bool isLessonComplete(int bookId, int lessonId) {
    final key = '$bookId-$lessonId';
    final progress = lessonProgress[key];
    return progress != null &&
        progress.learn &&
        progress.vocab &&
        progress.grammar &&
        progress.chat;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryWhite,
        appBar: AppBar(
          backgroundColor: AppColors.primaryWhite,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          ),
          title: const Text(
            'Giáo trình',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (textbooks.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primaryWhite,
        appBar: AppBar(
          backgroundColor: AppColors.primaryWhite,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          ),
          title: const Text(
            'Giáo trình',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: Text('Không có giáo trình')),
      );
    }

    final currentTextbook = textbooks.firstWhere(
      (t) => t.bookNumber == currentBook,
      orElse: () => textbooks.first,
    );

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
        ),
        title: const Text(
          'Giáo trình',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContinueLearningCard(
              textbook: currentTextbook,
              currentBook: currentBook,
              currentLesson: currentLesson,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LearningCurriculumScreen(
                      bookId: currentBook,
                      lessonId: currentLesson,
                      bookTitle: currentTextbook.title,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Danh sách giáo trình',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 16),
            ...textbooks.map((textbook) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTextbookCard(textbook),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextbookCard(Textbook textbook) {
    final isExpanded = expandedBookId == textbook.bookNumber;
    final progress = textbook.completedLessons / textbook.totalLessons;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textbook.isLocked
              ? AppColors.primaryBlack.withOpacity(0.1)
              : (textbook.bookNumber == currentBook
                  ? AppColors.primaryYellow
                  : AppColors.primaryBlack.withOpacity(0.1)),
          width: textbook.bookNumber == currentBook ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: textbook.isLocked ? null : () => toggleBook(textbook.bookNumber),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: textbook.isLocked
                            ? [
                                AppColors.primaryBlack.withOpacity(0.3),
                                AppColors.primaryBlack.withOpacity(0.2),
                              ]
                            : [
                                AppColors.primaryYellow,
                                AppColors.primaryYellow.withOpacity(0.8),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: textbook.isLocked
                          ? const Icon(
                              Icons.lock,
                              color: AppColors.primaryWhite,
                              size: 28,
                            )
                          : Text(
                              '${textbook.bookNumber}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                textbook.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textbook.isLocked
                                      ? AppColors.primaryBlack.withOpacity(0.5)
                                      : AppColors.primaryBlack,
                                ),
                              ),
                            ),
                            if (textbook.bookNumber == currentBook)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryYellow,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryBlack,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Đang học',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              )
                            else if (textbook.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Hoàn thành',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryWhite,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          textbook.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: textbook.isLocked
                                ? AppColors.primaryBlack.withOpacity(0.4)
                                : AppColors.primaryBlack.withOpacity(0.6),
                          ),
                        ),
                        if (!textbook.isLocked) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${textbook.completedLessons}/${textbook.totalLessons} bài',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: AppColors.primaryBlack.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryYellow),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!textbook.isLocked)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.primaryBlack,
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && !textbook.isLocked)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                children: List.generate(
                  textbook.totalLessons,
                  (index) {
                    final lessonId = index + 1;
                    final key = '${textbook.bookNumber}-$lessonId';
                    final progress = lessonProgress[key];
                    final isUnlocked = progress?.unlocked ?? false;
                    final isComplete = isLessonComplete(textbook.bookNumber, lessonId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.primaryWhite
                            : AppColors.primaryBlack.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryBlack.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isComplete
                                      ? AppColors.primaryYellow
                                      : isUnlocked
                                          ? AppColors.primaryYellow.withOpacity(0.2)
                                          : AppColors.primaryBlack.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryBlack,
                                    width: 1,
                                  ),
                                ),
                                child: isComplete
                                    ? const Icon(
                                        Icons.check,
                                        color: AppColors.primaryBlack,
                                        size: 20,
                                      )
                                    : isUnlocked
                                        ? const Icon(
                                            Icons.book_outlined,
                                            color: AppColors.primaryBlack,
                                            size: 20,
                                          )
                                        : const Icon(
                                            Icons.lock,
                                            color: AppColors.primaryBlack,
                                            size: 20,
                                          ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bài $lessonId: Bài học $lessonId',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isUnlocked
                                            ? AppColors.primaryBlack
                                            : AppColors.primaryBlack.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Nội dung bài học $lessonId',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primaryBlack.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (isUnlocked) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: LessonButton(
                                    label: 'Học',
                                    icon: Icons.school,
                                    isCompleted: progress?.learn ?? false,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LearningCurriculumScreen(
                                            bookId: textbook.bookNumber,
                                            lessonId: lessonId,
                                            bookTitle: textbook.title,
                                          ),
                                        ),
                                      );
                                      updateLessonProgress(textbook.bookNumber, lessonId, 'learn');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: LessonButton(
                                    label: 'Từ vựng',
                                    icon: Icons.book,
                                    isCompleted: progress?.vocab ?? false,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VocabularyScreen(
                                            bookId: textbook.bookNumber,
                                            lessonId: lessonId,
                                          ),
                                        ),
                                      );
                                      updateLessonProgress(textbook.bookNumber, lessonId, 'vocab');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: LessonButton(
                                    label: 'Ngữ pháp',
                                    icon: Icons.translate,
                                    isCompleted: progress?.grammar ?? false,
                                    onTap: () {
                                      updateLessonProgress(textbook.bookNumber, lessonId, 'grammar');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: LessonButton(
                                    label: 'Chat AI',
                                    icon: Icons.chat_bubble_outline,
                                    isCompleted: progress?.chat ?? false,
                                    onTap: () {
                                      updateLessonProgress(textbook.bookNumber, lessonId, 'chat');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

