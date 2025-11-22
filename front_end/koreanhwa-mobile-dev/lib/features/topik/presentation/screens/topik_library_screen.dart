import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/models/exam_model.dart';
import 'package:koreanhwa_flutter/services/exam_service.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screen/topik_detail_screen.dart';
import 'package:koreanhwa_flutter/shared/widgets/exam_card.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/widgets/topik_category_chip.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/widgets/topik_tab_button.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/widgets/topik_user_profile_card.dart';

class TopikLibraryScreen extends StatefulWidget {
  const TopikLibraryScreen({super.key});

  @override
  State<TopikLibraryScreen> createState() => _TopikLibraryScreenState();
}

class _TopikLibraryScreenState extends State<TopikLibraryScreen> {
  String _activeTab = 'all';
  String _activeCategory = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExamModel> get _filteredExams {
    return ExamService.filterExams(
      category: _activeCategory == 'Tất cả' ? null : _activeCategory,
      searchQuery: _searchController.text,
    );
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
                itemCount: ExamService.examCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = ExamService.examCategories[index];
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
            if (_filteredExams.isEmpty)
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
                  return ExamCard(
                    exam: exam,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopikDetailScreen(
                            examId: exam.id,
                            examTitle: exam.title,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

