import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/learning_curriculum_mock_data.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/widgets/lesson_tab_button.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/widgets/vocabulary_card.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/widgets/grammar_card.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/widgets/exercise_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final lessonData = LearningCurriculumMockData.lessonData;
    final tabs = LearningCurriculumMockData.tabs;

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: Column(
        children: [
          _buildHeader(lessonData),
          _buildTabs(tabs),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> lessonData) {
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
                    lessonData['title'] as String,
                    style: const TextStyle(
                      color: AppColors.primaryWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${lessonData['level']} • ${lessonData['duration']}',
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
                      value: (lessonData['progress'] as int) / 100,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryYellow),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${lessonData['progress']}%',
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
    switch (_activeTab) {
      case 'video':
        return _buildVideoTab();
      case 'vocabulary':
        return _buildVocabularyTab();
      case 'listening':
        return _buildListeningTab();
      case 'grammar':
        return _buildGrammarTab();
      case 'exercise':
        return _buildExerciseTab();
      case 'ai-chat':
        return _buildAIChatTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVideoTab() {
    final lessonData = LearningCurriculumMockData.lessonData;
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
                              value: 0.3,
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
          lessonData['title'] as String,
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
    final vocabulary = LearningCurriculumMockData.vocabulary;
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
        GridView.builder(
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
    final grammar = LearningCurriculumMockData.grammar;
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
        ...grammar.map((item) => GrammarCard(grammar: item)),
      ],
    );
  }

  Widget _buildExerciseTab() {
    final exercises = LearningCurriculumMockData.exercises;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bài tập kiểm tra',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 16),
        ...exercises.asMap().entries.map((entry) {
          return ExerciseCard(
            exercise: entry.value,
            index: entry.key,
          );
        }).toList(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlack,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.primaryBlack, width: 1),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Nộp bài',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
        Container(
          height: 300,
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
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryYellow,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Xin chào! Tôi có thể giúp gì cho bạn về bài học hôm nay?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryBlack,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Tôi muốn luyện phát âm từ "안녕하세요"',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: AppColors.primaryBlack,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
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
      ],
    );
  }
}

