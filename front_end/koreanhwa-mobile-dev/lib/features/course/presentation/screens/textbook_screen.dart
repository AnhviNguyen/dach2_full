import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary_screen.dart';

class TextbookScreen extends StatefulWidget {
  const TextbookScreen({super.key});

  @override
  State<TextbookScreen> createState() => _TextbookScreenState();
}

class _TextbookScreenState extends State<TextbookScreen> {
  // User is currently on Book 2, Lesson 8
  int currentBook = 2;
  int currentLesson = 8;
  int? expandedBookId;

  final Map<String, _LessonProgress> lessonProgress = {};

  @override
  void initState() {
    super.initState();
    // Initialize progress for all lessons
    for (int book = 1; book <= 6; book++) {
      for (int lesson = 1; lesson <= 15; lesson++) {
        final key = '$book-$lesson';
        final isUnlocked = book == 1 || (book == 2 && lesson <= 8);
        lessonProgress[key] = _LessonProgress(
          unlocked: isUnlocked,
          learn: book == 1 || (book == 2 && lesson < 8),
          vocab: book == 1 || (book == 2 && lesson < 8),
          grammar: book == 1 || (book == 2 && lesson < 8),
          chat: false,
        );
      }
    }
  }

  final List<_Textbook> textbooks = List.generate(6, (index) {
    final bookNumber = index + 1;
    final completedLessons = bookNumber == 1 ? 15 : (bookNumber == 2 ? 8 : 0);
    return _Textbook(
      bookNumber: bookNumber,
      title: 'Giáo trình Tiếng Hàn Quyển $bookNumber',
      subtitle: bookNumber == 1
          ? 'Sơ cấp 1'
          : bookNumber == 2
              ? 'Sơ cấp 2'
              : bookNumber == 3
                  ? 'Trung cấp 1'
                  : bookNumber == 4
                      ? 'Trung cấp 2'
                      : bookNumber == 5
                          ? 'Cao cấp 1'
                          : 'Cao cấp 2',
      totalLessons: 15,
      completedLessons: completedLessons,
      isCompleted: completedLessons == 15,
      isLocked: bookNumber > 2,
      color: AppColors.primaryYellow,
    );
  });

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
            lessonProgress[key] = _LessonProgress(
              unlocked: progress.unlocked,
              learn: !progress.learn,
              vocab: progress.vocab,
              grammar: progress.grammar,
              chat: progress.chat,
            );
            break;
          case 'vocab':
            lessonProgress[key] = _LessonProgress(
              unlocked: progress.unlocked,
              learn: progress.learn,
              vocab: !progress.vocab,
              grammar: progress.grammar,
              chat: progress.chat,
            );
            break;
          case 'grammar':
            lessonProgress[key] = _LessonProgress(
              unlocked: progress.unlocked,
              learn: progress.learn,
              vocab: progress.vocab,
              grammar: !progress.grammar,
              chat: progress.chat,
            );
            break;
          case 'chat':
            lessonProgress[key] = _LessonProgress(
              unlocked: progress.unlocked,
              learn: progress.learn,
              vocab: progress.vocab,
              grammar: progress.grammar,
              chat: !progress.chat,
            );
            break;
        }

        // Unlock next lesson if all parts completed
        final newProgress = lessonProgress[key]!;
        if (newProgress.learn &&
            newProgress.vocab &&
            newProgress.grammar &&
            newProgress.chat) {
          int nextLesson = lessonId + 1;
          int nextBook = bookId;
          if (nextLesson > 15) {
            nextLesson = 1;
            nextBook = bookId + 1;
          }
          if (nextBook <= 6) {
            final nextKey = '$nextBook-$nextLesson';
            lessonProgress[nextKey] = _LessonProgress(
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
    final currentTextbook = textbooks[currentBook - 1];

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
            // Continue learning card
            _buildContinueLearningCard(currentTextbook),
            const SizedBox(height: 24),
            // Section header
            const Text(
              'Danh sách giáo trình',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 16),
            // Textbook list
            ...textbooks.map((textbook) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTextbookCard(textbook),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueLearningCard(_Textbook textbook) {
    final currentKey = '$currentBook-$currentLesson';
    final progress = lessonProgress[currentKey];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryYellow,
            AppColors.primaryYellow.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryYellow.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  size: 32,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TIẾP TỤC HỌC',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      textbook.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    Text(
                      'Bài $currentLesson: Bài học $currentLesson',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlack.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LearningCurriculumScreen(
                    bookId: currentBook,
                    lessonId: currentLesson,
                    bookTitle: textbook.title,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlack,
              foregroundColor: AppColors.primaryWhite,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Học ngay',
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
        ],
      ),
    );
  }

  Widget _buildTextbookCard(_Textbook textbook) {
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
          // Book header
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
          // Lessons list
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
                    final isComplete = isLessonComplete(
                        textbook.bookNumber, lessonId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.primaryWhite
                            : AppColors.primaryBlack.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isUnlocked
                              ? AppColors.primaryBlack.withOpacity(0.1)
                              : AppColors.primaryBlack.withOpacity(0.1),
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
                                          ? AppColors.primaryYellow
                                              .withOpacity(0.2)
                                          : AppColors.primaryBlack
                                              .withOpacity(0.2),
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
                                            : AppColors.primaryBlack
                                                .withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Nội dung bài học $lessonId',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primaryBlack
                                            .withOpacity(0.6),
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
                                  child: _buildLessonButton(
                                    'Học',
                                    Icons.school,
                                    progress?.learn ?? false,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LearningCurriculumScreen(
                                            bookId: textbook.bookNumber,
                                            lessonId: lessonId,
                                            bookTitle: textbook.title,
                                          ),
                                        ),
                                      );
                                      updateLessonProgress(
                                          textbook.bookNumber, lessonId, 'learn');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildLessonButton(
                                    'Từ vựng',
                                    Icons.book,
                                    progress?.vocab ?? false,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VocabularyScreen(
                                            bookId: textbook.bookNumber,
                                            lessonId: lessonId,
                                          ),
                                        ),
                                      );
                                      updateLessonProgress(
                                          textbook.bookNumber, lessonId, 'vocab');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLessonButton(
                                    'Ngữ pháp',
                                    Icons.translate,
                                    progress?.grammar ?? false,
                                    () {
                                      updateLessonProgress(textbook.bookNumber,
                                          lessonId, 'grammar');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildLessonButton(
                                    'Chat AI',
                                    Icons.chat_bubble_outline,
                                    progress?.chat ?? false,
                                    () {
                                      updateLessonProgress(
                                          textbook.bookNumber, lessonId, 'chat');
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

  Widget _buildLessonButton(
      String label, IconData icon, bool isCompleted, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.primaryYellow
              : AppColors.primaryBlack.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColors.primaryBlack
                : AppColors.primaryBlack.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleted)
              const Icon(
                Icons.check,
                size: 16,
                color: AppColors.primaryBlack,
              )
            else
              Icon(
                icon,
                size: 16,
                color: AppColors.primaryBlack.withOpacity(0.7),
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? AppColors.primaryBlack
                    : AppColors.primaryBlack.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Textbook {
  final int bookNumber;
  final String title;
  final String subtitle;
  final int totalLessons;
  final int completedLessons;
  final bool isCompleted;
  final bool isLocked;
  final Color color;

  const _Textbook({
    required this.bookNumber,
    required this.title,
    required this.subtitle,
    required this.totalLessons,
    required this.completedLessons,
    this.isCompleted = false,
    this.isLocked = false,
    required this.color,
  });
}

class _LessonProgress {
  final bool unlocked;
  final bool learn;
  final bool vocab;
  final bool grammar;
  final bool chat;

  _LessonProgress({
    required this.unlocked,
    required this.learn,
    required this.vocab,
    required this.grammar,
    required this.chat,
  });
}
