import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/match_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/quiz_screen.dart';
import 'package:koreanhwa_flutter/models/vocabulary_folder_model.dart';
import 'package:koreanhwa_flutter/services/vocabulary_folder_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/flashcard_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/pronunciation_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/listen_write_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/vocab_test_screen.dart';

class FolderDetailScreen extends StatefulWidget {
  final int folderId;

  const FolderDetailScreen({super.key, required this.folderId});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  VocabularyFolder? _folder;
  VocabularyWord? _editingWord;

  @override
  void initState() {
    super.initState();
    _loadFolder();
  }

  void _loadFolder() {
    setState(() {
      _folder = VocabularyFolderService.getFolderById(widget.folderId);
    });
  }

  void _showAddWordDialog() {
    final koreanController = TextEditingController();
    final vietnameseController = TextEditingController();
    final pronunciationController = TextEditingController();
    final exampleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.primaryBlack, width: 2),
        ),
        title: const Text(
          'Thêm Từ Vựng Mới',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: koreanController,
                decoration: InputDecoration(
                  labelText: 'Tiếng Hàn *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlack),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pronunciationController,
                decoration: InputDecoration(
                  labelText: 'Phiên âm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlack),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vietnameseController,
                decoration: InputDecoration(
                  labelText: 'Tiếng Việt *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlack),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: exampleController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Câu ví dụ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlack),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppColors.primaryBlack)),
          ),
          ElevatedButton(
            onPressed: () {
              if (koreanController.text.trim().isNotEmpty &&
                  vietnameseController.text.trim().isNotEmpty) {
                final newWord = VocabularyWord(
                  id: DateTime.now().millisecondsSinceEpoch,
                  korean: koreanController.text.trim(),
                  vietnamese: vietnameseController.text.trim(),
                  pronunciation: pronunciationController.text.trim(),
                  example: exampleController.text.trim(),
                );
                VocabularyFolderService.addWordToFolder(widget.folderId, newWord);
                _loadFolder();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Thêm', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditWordDialog(VocabularyWord word) {
    final koreanController = TextEditingController(text: word.korean);
    final vietnameseController = TextEditingController(text: word.vietnamese);
    final pronunciationController = TextEditingController(text: word.pronunciation);
    final exampleController = TextEditingController(text: word.example);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.primaryBlack, width: 2),
        ),
        title: const Text(
          'Chỉnh Sửa Từ Vựng',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: koreanController,
                decoration: InputDecoration(
                  labelText: 'Tiếng Hàn *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlack),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pronunciationController,
                decoration: InputDecoration(
                  labelText: 'Phiên âm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlack),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vietnameseController,
                decoration: InputDecoration(
                  labelText: 'Tiếng Việt *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlack),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: exampleController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Câu ví dụ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlack),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppColors.primaryBlack)),
          ),
          ElevatedButton(
            onPressed: () {
              if (koreanController.text.trim().isNotEmpty &&
                  vietnameseController.text.trim().isNotEmpty) {
                final updatedWord = VocabularyWord(
                  id: word.id,
                  korean: koreanController.text.trim(),
                  vietnamese: vietnameseController.text.trim(),
                  pronunciation: pronunciationController.text.trim(),
                  example: exampleController.text.trim(),
                );
                VocabularyFolderService.updateWordInFolder(widget.folderId, updatedWord);
                _loadFolder();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateToLearningMode(String mode) {
    if (_folder == null || _folder!.words.isEmpty) return;

    final vocabList = _folder!.words.map((word) => {
      'korean': word.korean,
      'vietnamese': word.vietnamese,
      'pronunciation': word.pronunciation,
      'example': word.example,
    }).toList();

    Widget? screen;
    switch (mode) {
      case 'flashcard':
        screen = FlashcardScreen(
          bookId: 0,
          lessonId: 0,
          vocabList: vocabList,
        );
        break;
      case 'match':
        screen = MatchScreen(
          bookId: 0,
          lessonId: 0,
          vocabList: vocabList,
        );
        break;
      case 'pronunciation':
        screen = PronunciationScreen(
          bookId: 0,
          lessonId: 0,
          vocabList: vocabList,
        );
        break;
      case 'quiz':
        screen = QuizScreen(
          bookId: 0,
          lessonId: 0,
          vocabList: vocabList,
        );
        break;
      case 'listen':
        screen = ListenWriteScreen(
          bookId: 0,
          lessonId: 0,
          vocabList: vocabList,
        );
        break;
      case 'test':
        screen = VocabTestScreen(
          bookId: 0,
          lessonId: 0,
          vocabList: vocabList,
        );
        break;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_folder == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Folder không tồn tại'),
        ),
        body: const Center(child: Text('Folder không tồn tại')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
        ),
        title: Row(
          children: [
            Text(_folder!.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _folder!.name,
                    style: const TextStyle(
                      color: AppColors.primaryBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${_folder!.words.length} từ vựng',
                    style: TextStyle(
                      color: AppColors.primaryBlack.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAddWordDialog,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: AppColors.primaryBlack),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Learning modes
            if (_folder!.words.length >= 4) ...[
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
                  _buildLearningModeButton(
                    'Flashcard',
                    Icons.book,
                    const Color(0xFF2196F3),
                    () => _navigateToLearningMode('flashcard'),
                  ),
                  _buildLearningModeButton(
                    'Match',
                    Icons.shuffle,
                    const Color(0xFF9C27B0),
                    () => _navigateToLearningMode('match'),
                  ),
                  _buildLearningModeButton(
                    'Pronunciation',
                    Icons.volume_up,
                    const Color(0xFF4CAF50),
                    () => _navigateToLearningMode('pronunciation'),
                  ),
                  _buildLearningModeButton(
                    'Quiz',
                    Icons.quiz,
                    const Color(0xFFF44336),
                    () => _navigateToLearningMode('quiz'),
                  ),
                  _buildLearningModeButton(
                    'Listen & Write',
                    Icons.headphones,
                    const Color(0xFFFF9800),
                    () => _navigateToLearningMode('listen'),
                  ),
                  _buildLearningModeButton(
                    'Test',
                    Icons.edit,
                    const Color(0xFFE91E63),
                    () => _navigateToLearningMode('test'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            // Words list
            const Text(
              'Danh sách từ vựng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 12),
            if (_folder!.words.isEmpty)
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.whiteGray,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.book,
                        size: 48,
                        color: AppColors.grayLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có từ vựng nào',
                      style: TextStyle(
                        color: AppColors.primaryBlack.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showAddWordDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlack,
                      ),
                      child: const Text('Thêm từ vựng đầu tiên'),
                    ),
                  ],
                ),
              )
            else
              ..._folder!.words.map((word) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryBlack.withOpacity(0.1),
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
                                word.korean,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                word.pronunciation,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryBlack.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                word.vietnamese,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                              if (word.example.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteGray,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    word.example,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryBlack.withOpacity(0.5),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => _showEditWordDialog(word),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xóa từ này?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          VocabularyFolderService.deleteWordFromFolder(
                                            widget.folderId,
                                            word.id,
                                          );
                                          _loadFolder();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningModeButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
            Icon(icon, size: 32, color: AppColors.primaryWhite),
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

