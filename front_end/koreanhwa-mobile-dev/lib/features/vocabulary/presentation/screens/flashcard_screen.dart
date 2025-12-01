import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/home/data/services/task_progress_service.dart';
import 'package:koreanhwa_flutter/core/utils/user_utils.dart';

class FlashcardScreen extends StatefulWidget {
  final int bookId;
  final int lessonId;
  final List<Map<String, String>> vocabList;

  const FlashcardScreen({
    super.key,
    required this.bookId,
    required this.lessonId,
    required this.vocabList,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  int _currentCardIndex = 0;
  bool _isFlipped = false;
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  final TaskProgressService _taskProgressService = TaskProgressService();
  final Set<int> _viewedCards = {}; // Track cards đã xem

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
      setState(() => _isFlipped = false);
    } else {
      _animationController.forward();
      setState(() => _isFlipped = true);
      // Đánh dấu card đã xem
      _viewedCards.add(_currentCardIndex);
      // Kiểm tra nếu đã xem hết tất cả cards
      _checkCompletion();
    }
  }
  
  Future<void> _checkCompletion() async {
    // Nếu đã xem >= 80% số cards, đánh dấu hoàn thành
    if (_viewedCards.length >= (widget.vocabList.length * 0.8).ceil()) {
      try {
        final userId = await UserUtils.getUserId();
        if (userId != null) {
          await _taskProgressService.completeVocabularyFlashcard(
            userId: userId,
            bookId: widget.bookId,
            lessonId: widget.lessonId,
          );
          debugPrint('✅ Task progress updated for vocabulary flashcard');
        }
      } catch (e) {
        debugPrint('⚠️ Failed to update task progress: $e');
      }
    }
  }

  void _nextCard() {
    setState(() {
      _isFlipped = false;
      _animationController.reset();
      _currentCardIndex = (_currentCardIndex + 1) % widget.vocabList.length;
    });
  }

  void _prevCard() {
    setState(() {
      _isFlipped = false;
      _animationController.reset();
      _currentCardIndex =
          (_currentCardIndex - 1 + widget.vocabList.length) %
              widget.vocabList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vocab = widget.vocabList[_currentCardIndex];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.primaryWhite),
        ),
        title: Text(
          'Flashcard',
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
                '${_currentCardIndex + 1} / ${widget.vocabList.length}',
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * 3.14159;
                  final isFront = angle < 3.14159 / 2;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: isFront ? _buildFront(vocab) : _buildBack(vocab),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isFlipped ? 'Chạm để xem mặt trước' : 'Chạm để xem mặt sau',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlack.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _prevCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: AppColors.primaryWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
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
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _nextCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFront(Map<String, String> vocab) {
    return Container(
      width: 350,
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2196F3),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            vocab['korean']!,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            vocab['pronunciation']!,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.primaryBlack.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBack(Map<String, String> vocab) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        width: 350,
        height: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryBlack,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryYellow.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              vocab['vietnamese']!,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              vocab['example']!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlack.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

