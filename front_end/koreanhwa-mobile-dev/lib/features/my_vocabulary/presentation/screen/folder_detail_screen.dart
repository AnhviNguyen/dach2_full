import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/match_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/quiz_screen.dart';
import 'package:koreanhwa_flutter/models/vocabulary_folder_model.dart';
import 'package:koreanhwa_flutter/features/my_vocabulary/data/services/vocabulary_folder_api_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/flashcard_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/pronunciation_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/listen_write_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/vocab_test_screen.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/widgets/learning_mode_button.dart';
import 'package:koreanhwa_flutter/features/vocabulary/data/models/learning_mode.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/widgets/vocabulary_info_card.dart';

class FolderDetailScreen extends ConsumerStatefulWidget {
  final int folderId;

  const FolderDetailScreen({super.key, required this.folderId});

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  final VocabularyFolderApiService _apiService = VocabularyFolderApiService();
  VocabularyFolder? _folder;
  VocabularyWord? _editingWord;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFolder();
  }

  Future<void> _loadFolder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final folder = await _apiService.getFolderById(widget.folderId, userId);
      setState(() {
        _folder = folder;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showAddWordDialog() {
    final koreanController = TextEditingController();
    final vietnameseController = TextEditingController();
    final pronunciationController = TextEditingController();
    final exampleController = TextEditingController();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.primaryBlack, width: 2),
        ),
        title: Text(
          'Thêm Từ Vựng Mới',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack),
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
            onPressed: () async {
              if (koreanController.text.trim().isNotEmpty &&
                  vietnameseController.text.trim().isNotEmpty) {
                try {
                  final userId = ref.read(authProvider).user?.id;
                  if (userId == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng đăng nhập')),
                      );
                    }
                    return;
                  }

                  await _apiService.addWordToFolder(
                    folderId: widget.folderId,
                    korean: koreanController.text.trim(),
                    vietnamese: vietnameseController.text.trim(),
                    pronunciation: pronunciationController.text.trim(),
                    example: exampleController.text.trim(),
                    userId: userId,
                  );
                  await _loadFolder();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                  }
                }
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
    final pronunciationController = TextEditingController(text: word.pronunciation ?? '');
    final exampleController = TextEditingController(text: word.example ?? '');

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.primaryBlack, width: 2),
        ),
        title: Text(
          'Chỉnh Sửa Từ Vựng',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack),
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
            onPressed: () async {
              if (koreanController.text.trim().isNotEmpty &&
                  vietnameseController.text.trim().isNotEmpty) {
                try {
                  final userId = ref.read(authProvider).user?.id;
                  if (userId == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng đăng nhập')),
                      );
                    }
                    return;
                  }

                  await _apiService.updateWord(
                    wordId: word.id,
                    korean: koreanController.text.trim(),
                    vietnamese: vietnameseController.text.trim(),
                    pronunciation: pronunciationController.text.trim(),
                    example: exampleController.text.trim(),
                    userId: userId,
                  );
                  await _loadFolder();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                  }
                }
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

  List<Map<String, String>> _getVocabList() {
    if (_folder == null || _folder!.words.isEmpty) return [];
    return _folder!.words.map((word) => {
      'korean': word.korean,
      'vietnamese': word.vietnamese,
      'pronunciation': word.pronunciation ?? '',
      'example': word.example ?? '',
    }).toList();
  }

  void _navigateToLearningMode(String modeId) {
    final vocabList = _getVocabList();
    if (vocabList.isEmpty) return;

    Widget? screen;
    switch (modeId) {
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
      case 'listen_write':
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _folder == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage ?? 'Folder không tồn tại',
                style: TextStyle(color: theme.textTheme.bodyLarge?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFolder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.primaryBlack,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
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
            if (_folder!.words.isNotEmpty) ...[
              VocabularyInfoCard(totalWords: _folder!.words.length),
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
                children: [
                  LearningModeButton(
                    mode: const LearningMode(
                      id: 'flashcard',
                      name: 'Flashcard',
                      icon: Icons.book,
                      color: Color(0xFF2196F3),
                    ),
                    onTap: () => _navigateToLearningMode('flashcard'),
                  ),
                  LearningModeButton(
                    mode: const LearningMode(
                      id: 'match',
                      name: 'Ghép từ',
                      icon: Icons.compare_arrows,
                      color: Color(0xFF4CAF50),
                    ),
                    onTap: () => _navigateToLearningMode('match'),
                  ),
                  LearningModeButton(
                    mode: const LearningMode(
                      id: 'pronunciation',
                      name: 'Phát âm',
                      icon: Icons.record_voice_over,
                      color: Color(0xFF9C27B0),
                    ),
                    onTap: () => _navigateToLearningMode('pronunciation'),
                  ),
                  LearningModeButton(
                    mode: const LearningMode(
                      id: 'quiz',
                      name: 'Trắc nghiệm',
                      icon: Icons.quiz,
                      color: Color(0xFFFF9800),
                    ),
                    onTap: () => _navigateToLearningMode('quiz'),
                  ),
                  LearningModeButton(
                    mode: const LearningMode(
                      id: 'listen_write',
                      name: 'Nghe - Viết',
                      icon: Icons.hearing,
                      color: Color(0xFFE91E63),
                    ),
                    onTap: () => _navigateToLearningMode('listen_write'),
                  ),
                  LearningModeButton(
                    mode: const LearningMode(
                      id: 'test',
                      name: 'Kiểm tra',
                      icon: Icons.assignment,
                      color: Color(0xFFF44336),
                    ),
                    onTap: () => _navigateToLearningMode('test'),
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
                      color: Theme.of(context).cardColor,
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
                              if (word.pronunciation != null && word.pronunciation!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  word.pronunciation!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primaryBlack.withOpacity(0.6),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                word.vietnamese,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                              if (word.example != null && word.example!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteGray,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    word.example!,
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
                                        onPressed: () async {
                                          try {
                                            final userId = ref.read(authProvider).user?.id;
                                            if (userId == null) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Vui lòng đăng nhập')),
                                                );
                                              }
                                              return;
                                            }

                                            await _apiService.deleteWord(word.id, userId);
                                            await _loadFolder();
                                            if (mounted) {
                                              Navigator.pop(context);
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Lỗi: ${e.toString()}')),
                                              );
                                            }
                                          }
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

}

