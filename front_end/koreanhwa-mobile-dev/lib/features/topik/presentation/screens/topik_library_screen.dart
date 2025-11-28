import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/models/exam_model.dart';
import 'package:koreanhwa_flutter/features/topik/data/services/topik_api_service.dart';
import 'package:koreanhwa_flutter/features/topik/data/models/topik_exam.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screen/topik_detail_screen.dart';
import 'package:koreanhwa_flutter/shared/widgets/exam_card.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/widgets/topik_category_chip.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/widgets/topik_tab_button.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/widgets/topik_user_profile_card.dart';
import 'package:koreanhwa_flutter/features/topik/data/services/exam_result_service.dart';

class TopikLibraryScreen extends StatefulWidget {
  const TopikLibraryScreen({super.key});

  @override
  State<TopikLibraryScreen> createState() => _TopikLibraryScreenState();
}

class _TopikLibraryScreenState extends State<TopikLibraryScreen> {
  String _activeTab = 'all';
  String _activeCategory = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();
  final TopikApiService _apiService = TopikApiService();
  
  List<TopikExam> _exams = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<String> _completedExamIds = {};

  @override
  void initState() {
    super.initState();
    _loadExams();
    _loadCompletedExams();
  }

  Future<void> _loadCompletedExams() async {
    final completedIds = await ExamResultService.getCompletedExamIds();
    setState(() {
      _completedExamIds = completedIds;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getExams();
      final examsList = (response['exams'] as List<dynamic>?)
          ?.map((e) => TopikExam.fromJson({'examNumber': e.toString()}))
          .toList() ?? [];
      
      setState(() {
        _exams = examsList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải danh sách đề thi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<ExamModel> get _filteredExams {
    var filtered = _exams.map((exam) => ExamModel(
      id: exam.id,
      title: exam.displayTitle,
      duration: exam.duration,
      participants: exam.participants,
      questions: exam.questions,
      tags: exam.tags,
    )).toList();

    if (_activeCategory != 'Tất cả') {
      filtered = filtered
          .where((exam) => exam.tags.any((tag) => tag.contains(_activeCategory)))
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((exam) =>
              exam.title.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
        ),
        title: const Text(
          'Thư viện đề thi tiếng Hàn',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thư viện đề thi tiếng Hàn',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đánh giá năng lực tiếng Hàn toàn diện',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlack.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return TopikCategoryChip(
                    category: category,
                    isSelected: _activeCategory == category,
                    onTap: () {
                      setState(() {
                        _activeCategory = category;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đề thi...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlack),
                filled: true,
                fillColor: AppColors.primaryWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.primaryBlack.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.primaryBlack.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primaryYellow,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TopikTabButton(
                    label: 'Tất cả',
                    isSelected: _activeTab == 'all',
                    onTap: () => setState(() => _activeTab = 'all'),
                  ),
                ),
                Expanded(
                  child: TopikTabButton(
                    label: 'Đã rút gọn',
                    isSelected: _activeTab == 'removed',
                    onTap: () => setState(() => _activeTab = 'removed'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const TopikUserProfileCard(),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.primaryBlack.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadExams,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryBlack,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredExams.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.primaryBlack.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy bài thi nào phù hợp.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thử thay đổi từ khóa tìm kiếm hoặc chọn danh mục khác.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBlack.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _filteredExams.length,
                itemBuilder: (context, index) {
                  final exam = _filteredExams[index];
                  final isCompleted = _completedExamIds.contains(exam.id);
                  return ExamCard(
                    exam: exam,
                    isCompleted: isCompleted,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopikDetailScreen(
                            examId: exam.id,
                            examTitle: exam.title,
                          ),
                        ),
                      ).then((_) {
                        // Reload completed exams khi quay lại
                        _loadCompletedExams();
                      });
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  static const List<String> _categories = [
    'Tất cả',
    'TOPIK I',
    'TOPIK II',
  ];
}

