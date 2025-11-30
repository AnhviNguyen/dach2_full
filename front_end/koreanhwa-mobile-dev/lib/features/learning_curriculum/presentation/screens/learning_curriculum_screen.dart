import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/learning_curriculum_mock_data.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/widgets/lesson_tab_button.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/widgets/vocabulary_card.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/widgets/grammar_card.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/widgets/exercise_card.dart';
import 'package:koreanhwa_flutter/features/lessons/data/services/lesson_api_service.dart';
import 'package:koreanhwa_flutter/features/lessons/data/models/lesson_response.dart';
import 'package:koreanhwa_flutter/features/textbook/data/services/textbook_api_service.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/vocabulary_item.dart' as local;
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/grammar_item.dart' as local;
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/exercise_item.dart' as local;
import 'package:koreanhwa_flutter/features/learning_curriculum/data/services/chat_api_service.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/services/exercise_api_service.dart';
import 'package:koreanhwa_flutter/shared/widgets/dictionary_input_dialog.dart';

class LearningCurriculumScreen extends StatefulWidget {
  final int bookId;
  final int lessonId;
  final String bookTitle;

  const LearningCurriculumScreen({
    super.key,
    required this.bookId,
    required this.lessonId,
    required this.bookTitle,
  });

  @override
  State<LearningCurriculumScreen> createState() =>
      _LearningCurriculumScreenState();
}

class _LearningCurriculumScreenState extends State<LearningCurriculumScreen> {
  String _activeTab = 'video';
  bool _isMuted = false;
  bool _isFullscreen = false;
  final LessonApiService _lessonApiService = LessonApiService();
  final ChatApiService _chatApiService = ChatApiService();
  final ExerciseApiService _exerciseApiService = ExerciseApiService();
  LessonResponse? _lessonData;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Chat state
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  bool _isChatLoading = false;
  
  // Exercise state
  List<local.ExerciseItem> _generatedExercises = [];
  bool _isGeneratingExercises = false;
  Map<int, dynamic> _exerciseAnswers = {}; // exerciseId -> user answer
  bool _isExerciseSubmitted = false;
  Map<int, bool> _exerciseResults = {}; // exerciseId -> isCorrect

  @override
  void initState() {
    super.initState();
    _loadLessonData();
    _chatMessages.add({
      'role': 'assistant',
      'message': 'Xin chào! Tôi có thể giúp gì cho bạn về bài học hôm nay?',
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _loadLessonData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Lấy curriculum ID từ bookId
      final textbookApiService = TextbookApiService();
      final curriculum = await textbookApiService.getTextbookByBookNumber(widget.bookId);
      final curriculumId = curriculum.id;
      
      if (curriculumId == null) {
        throw Exception('Không tìm thấy giáo trình với số sách ${widget.bookId}');
      }

      // Lấy tất cả lessons của curriculum
      final lessonsResponse = await _lessonApiService.getCurriculumLessonsByCurriculumId(
        curriculumId,
        page: 0,
        size: 100,
      );
      
      // Tìm lesson có lessonNumber = widget.lessonId
      final lesson = lessonsResponse.content.firstWhere(
        (l) => l.lessonNumber == widget.lessonId,
        orElse: () {
          if (lessonsResponse.content.isNotEmpty) {
            return lessonsResponse.content.first;
          }
          throw Exception('Không tìm thấy bài học');
        },
      );

      // Lấy chi tiết curriculum lesson để có vocabulary, grammar, exercises
      final lessonDetail = await _lessonApiService.getCurriculumLessonById(lesson.id);
      
      setState(() {
        _lessonData = lessonDetail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu bài học: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = LearningCurriculumMockData.tabs;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryWhite,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.primaryWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.primaryBlack),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLessonData,
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

    if (_lessonData == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryWhite,
        body: const Center(child: Text('Không tìm thấy dữ liệu bài học')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: Column(
        children: [
          _buildHeader(_lessonData!),
          _buildTabs(tabs),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const DictionaryInputDialog(),
          );
        },
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.primaryBlack,
        elevation: 4,
        child: const Icon(Icons.translate),
      ),
    );
  }

  Widget _buildHeader(LessonResponse lessonData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryYellow,
            width: 4,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primaryWhite,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lessonData.title,
                    style: const TextStyle(
                      color: AppColors.primaryWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${lessonData.level} • ${lessonData.duration}',
                    style: const TextStyle(
                      color: AppColors.primaryYellow,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 120,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: lessonData.progress / 100,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryYellow),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${lessonData.progress}%',
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(List tabs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryBlack,
            width: 2,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            return LessonTabButton(
              tab: tab,
              isActive: _activeTab == tab.id,
              onTap: () {
                setState(() {
                  _activeTab = tab.id as String;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    Widget content;
    switch (_activeTab) {
      case 'video':
        content = _buildVideoTab();
        break;
      case 'vocabulary':
        content = _buildVocabularyTab();
        break;
      case 'listening':
        content = _buildListeningTab();
        break;
      case 'grammar':
        content = _buildGrammarTab();
        break;
      case 'exercise':
        content = _buildExerciseTab();
        break;
      case 'ai-chat':
        content = _buildAIChatTab();
        break;
      default:
        content = const SizedBox.shrink();
    }
    
    // Wrap non-chat tabs in SingleChildScrollView
    if (_activeTab != 'ai-chat') {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: content,
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildVideoTab() {
    if (_lessonData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.primaryBlack,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 64,
                      color: AppColors.primaryYellow,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Video bài giảng',
                      style: TextStyle(
                        color: AppColors.primaryWhite,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                        },
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _lessonData!.progress / 100,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryYellow),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isFullscreen = !_isFullscreen;
                          });
                        },
                        icon: Icon(
                          _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _lessonData!.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildVocabularyTab() {
    if (_lessonData == null) return const SizedBox.shrink();
    
    final vocabulary = _lessonData!.vocabulary.map((v) => local.VocabularyItem(
      korean: v.korean,
      vietnamese: v.vietnamese,
      pronunciation: v.pronunciation,
      example: v.example,
    )).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Từ vựng bài học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryBlack, width: 1),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Học bằng flashcard',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        vocabulary.isEmpty
            ? const Center(child: Text('Chưa có từ vựng'))
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: vocabulary.length,
                itemBuilder: (context, index) {
                  return VocabularyCard(vocabulary: vocabulary[index]);
                },
              ),
      ],
    );
  }

  Widget _buildListeningTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Luyện nghe',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryBlack,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bài tập 1: Nghe và chọn đáp án đúng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nghe câu sau và chọn nghĩa đúng:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlack,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: AppColors.primaryBlack,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '안녕하세요, 저는 마이클입니다.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildRadioOption('A', 'A. Xin chào, tôi là Michael', 'listening1'),
                  const SizedBox(height: 8),
                  _buildRadioOption('B', 'B. Tạm biệt, tôi là Michael', 'listening1'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value, String label, String group) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: null,
          onChanged: (val) {},
          activeColor: AppColors.primaryYellow,
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primaryBlack,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrammarTab() {
    if (_lessonData == null) return const SizedBox.shrink();
    
    final grammar = _lessonData!.grammar.map((g) => local.GrammarItem(
      title: g.title,
      explanation: g.explanation,
      examples: g.examples,
    )).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngữ pháp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 16),
        grammar.isEmpty
            ? const Center(child: Text('Chưa có ngữ pháp'))
            : Column(
                children: grammar.map((item) => GrammarCard(grammar: item)).toList(),
              ),
      ],
    );
  }

  Widget _buildExerciseTab() {
    if (_lessonData == null) return const SizedBox.shrink();
    
    // Use generated exercises if available, otherwise use lesson exercises
    final exercises = _generatedExercises.isNotEmpty 
        ? _generatedExercises
        : _lessonData!.exercises.map((e) => local.ExerciseItem(
            id: e.id,
            type: e.type,
            question: e.question,
            options: e.options,
            correct: e.correct,
            answer: e.answer,
          )).toList();
    
    // Reset submission state if exercises changed
    if (_isExerciseSubmitted && exercises.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isExerciseSubmitted = false;
            _exerciseAnswers.clear();
            _exerciseResults.clear();
          });
        }
      });
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bài tập kiểm tra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            if (!_isGeneratingExercises)
              ElevatedButton(
                onPressed: _generateExercises,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.primaryBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.primaryBlack, width: 1),
                  ),
                ),
                child: const Text('Sinh bài tập AI'),
              )
            else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        exercises.isEmpty
            ? const Center(child: Text('Chưa có bài tập'))
            : Column(
                children: exercises.asMap().entries.map((entry) {
                  return ExerciseCard(
                    exercise: entry.value,
                    index: entry.key,
                    onAnswerChanged: (exerciseId, answer) {
                      setState(() {
                        _exerciseAnswers[exerciseId] = answer;
                      });
                    },
                    isSubmitted: _isExerciseSubmitted,
                    showResult: _isExerciseSubmitted,
                  );
                }).toList(),
              ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isExerciseSubmitted ? null : _submitExercises,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlack,
              disabledBackgroundColor: AppColors.primaryBlack.withOpacity(0.3),
              disabledForegroundColor: AppColors.primaryBlack.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.primaryBlack, width: 1),
              ),
              elevation: 0,
            ),
            child: _isExerciseSubmitted
                ? const Text(
                    'Đã nộp bài',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Text(
                    'Nộp bài',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        if (_isExerciseSubmitted) ...[
          const SizedBox(height: 16),
          _buildExerciseResult(),
        ],
      ],
    );
  }

  Future<void> _generateExercises() async {
    setState(() {
      _isGeneratingExercises = true;
      _exerciseAnswers.clear();
      _isExerciseSubmitted = false;
      _exerciseResults.clear();
    });

    try {
      final data = await _exerciseApiService.generateExercises(
        bookId: widget.bookId,
        lessonId: widget.lessonId,
        count: 5,
      );

      final exercises = (data['exercises'] as List<dynamic>).map((e) {
        return local.ExerciseItem(
          id: e['id'] as int,
          type: e['type'] as String,
          question: e['question'] as String,
          options: e['options'] != null ? List<String>.from(e['options']) : null,
          correct: e['correct'],
          answer: e['answer'] as String?,
        );
      }).toList();

      setState(() {
        _generatedExercises = exercises;
        _isGeneratingExercises = false;
      });
    } catch (e) {
      setState(() {
        _isGeneratingExercises = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi sinh bài tập: ${e.toString()}')),
        );
      }
    }
  }

  void _submitExercises() {
    if (_generatedExercises.isEmpty && _lessonData?.exercises.isEmpty != false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có bài tập để nộp')),
      );
      return;
    }

    final exercises = _generatedExercises.isNotEmpty 
        ? _generatedExercises
        : _lessonData!.exercises.map((e) => local.ExerciseItem(
            id: e.id,
            type: e.type,
            question: e.question,
            options: e.options,
            correct: e.correct,
            answer: e.answer,
          )).toList();

    // Calculate results
    final results = <int, bool>{};
    int correctCount = 0;
    
    for (final exercise in exercises) {
      final userAnswer = _exerciseAnswers[exercise.id];
      bool isCorrect = false;
      
      if (exercise.type == 'multiple_choice') {
        if (exercise.correct != null && exercise.options != null && userAnswer != null) {
          final correctAnswer = exercise.options![exercise.correct!];
          isCorrect = userAnswer == correctAnswer;
        }
      } else if (exercise.type == 'fill_blank') {
        final userAnswerStr = (userAnswer?.toString() ?? '').trim().toLowerCase();
        final correctAnswer = (exercise.answer ?? '').trim().toLowerCase();
        isCorrect = userAnswerStr == correctAnswer;
      }
      
      results[exercise.id] = isCorrect;
      if (isCorrect) correctCount++;
    }

    setState(() {
      _isExerciseSubmitted = true;
      _exerciseResults = results;
    });

    // Show result dialog
    _showExerciseResultDialog(correctCount, exercises.length);
  }

  Widget _buildExerciseResult() {
    final exercises = _generatedExercises.isNotEmpty 
        ? _generatedExercises
        : _lessonData!.exercises.map((e) => local.ExerciseItem(
            id: e.id,
            type: e.type,
            question: e.question,
            options: e.options,
            correct: e.correct,
            answer: e.answer,
          )).toList();
    
    final correctCount = _exerciseResults.values.where((r) => r == true).length;
    final totalCount = exercises.length;
    final percentage = totalCount > 0 ? (correctCount / totalCount * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: percentage >= 80
            ? AppColors.success.withOpacity(0.1)
            : percentage >= 50
                ? AppColors.primaryYellow.withOpacity(0.1)
                : const Color(0xFFF44336).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: percentage >= 80
              ? AppColors.success
              : percentage >= 50
                  ? AppColors.primaryYellow
                  : const Color(0xFFF44336),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                percentage >= 80
                    ? Icons.check_circle
                    : percentage >= 50
                        ? Icons.info
                        : Icons.cancel,
                color: percentage >= 80
                    ? AppColors.success
                    : percentage >= 50
                        ? AppColors.primaryYellow
                        : const Color(0xFFF44336),
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '$correctCount/$totalCount câu đúng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 80
                      ? AppColors.success
                      : percentage >= 50
                          ? AppColors.primaryYellow
                          : const Color(0xFFF44336),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Độ chính xác: $percentage%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlack,
            ),
          ),
          if (percentage >= 80) ...[
            const SizedBox(height: 8),
            const Text(
              'Chúc mừng! Bạn đã hoàn thành tốt bài tập này.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'Hãy xem lại các câu sai và luyện tập thêm nhé!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _showExerciseResultDialog(int correctCount, int totalCount) {
    final percentage = totalCount > 0 ? (correctCount / totalCount * 100).round() : 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primaryBlack, width: 2),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percentage >= 80
                  ? Icons.check_circle
                  : percentage >= 50
                      ? Icons.info
                      : Icons.cancel,
              color: percentage >= 80
                  ? AppColors.success
                  : percentage >= 50
                      ? AppColors.primaryYellow
                      : const Color(0xFFF44336),
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              'Kết quả',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$correctCount/$totalCount câu đúng',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: percentage >= 80
                    ? AppColors.success
                    : percentage >= 50
                        ? AppColors.primaryYellow
                        : const Color(0xFFF44336),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Độ chính xác: $percentage%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 16),
            if (percentage >= 80)
              const Text(
                'Chúc mừng! Bạn đã hoàn thành tốt bài tập này.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryBlack,
                ),
                textAlign: TextAlign.center,
              )
            else
              const Text(
                'Hãy xem lại các câu sai và luyện tập thêm nhé!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryBlack,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlack,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Đóng',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIChatTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chat với AI',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBlack.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _chatMessages.map((msg) {
                        final isUser = msg['role'] == 'user';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              if (!isUser)
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryYellow,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryBlack,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.chat,
                                    size: 18,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              if (!isUser) const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUser ? AppColors.primaryYellow : AppColors.primaryWhite,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isUser ? AppColors.primaryBlack : AppColors.primaryYellow,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    msg['message'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                                      color: AppColors.primaryBlack,
                                    ),
                                  ),
                                ),
                              ),
                              if (isUser) const SizedBox(width: 8),
                              if (isUser)
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryWhite,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryBlack.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (_isChatLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlack,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryYellow,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendChatMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isChatLoading ? null : _sendChatMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: AppColors.primaryBlack,
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Gửi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendChatMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty || _isChatLoading) return;

    // Add user message
    setState(() {
      _chatMessages.add({
        'role': 'user',
        'message': message,
      });
      _chatController.clear();
      _isChatLoading = true;
    });

    try {
      final response = await _chatApiService.chatWithTeacher(
        message: message,
        mode: 'free_chat',
        context: {
          'book_id': widget.bookId,
          'lesson_id': widget.lessonId,
          'lesson_title': _lessonData?.title,
        },
      );

      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'message': response['reply'] as String? ?? 'Xin lỗi, tôi không thể trả lời.',
        });
        _isChatLoading = false;
      });
    } catch (e) {
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'message': 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.',
        });
        _isChatLoading = false;
      });
    }
  }
}

