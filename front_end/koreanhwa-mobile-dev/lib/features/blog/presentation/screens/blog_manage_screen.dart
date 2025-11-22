import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/models/blog_model.dart';
import 'package:koreanhwa_flutter/services/blog_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/blog/blog_detail_screen.dart';

class BlogManageScreen extends StatefulWidget {
  const BlogManageScreen({super.key});

  @override
  State<BlogManageScreen> createState() => _BlogManageScreenState();
}

class _BlogManageScreenState extends State<BlogManageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  List<BlogPost> _myPosts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPosts() {
    setState(() {
      _myPosts = BlogService.getPosts(tab: 'my');
    });
  }

  List<BlogPost> get _filteredPosts {
    var filtered = _myPosts;

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((post) => post.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    if (_selectedCategory != 'all') {
      filtered = filtered.where((post) => post.skill == _selectedCategory).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final totalViews = _myPosts.fold<int>(0, (sum, post) => sum + post.views);
    final totalTags = _myPosts.fold<int>(0, (sum, post) => sum + post.tags.length);
    final totalPoints = _myPosts.length * 10;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Quản lý Blog Của Bạn',
          style: TextStyle(
            color: AppColors.primaryWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryYellow),
            onPressed: () => context.push('/blog/create'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.article,
                      '${_myPosts.length}',
                      'Tổng bài viết',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.visibility,
                      '$totalViews',
                      'Lượt xem',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.label,
                      '$totalTags',
                      'Tổng thẻ',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.star,
                      '$totalPoints',
                      'Tổng số điểm',
                    ),
                  ),
                ],
              ),
            ),
            // Filters
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: AppColors.primaryWhite),
                      decoration: InputDecoration(
                        hintText: 'Tìm bài viết...',
                        hintStyle: TextStyle(color: AppColors.primaryWhite.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryYellow),
                        filled: true,
                        fillColor: AppColors.blackMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryYellow.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryYellow.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.blackMedium,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryYellow.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.filter_list, color: AppColors.primaryYellow),
                      dropdownColor: AppColors.blackMedium,
                      style: const TextStyle(color: AppColors.primaryWhite),
                      items: BlogService.getSkills().map((skill) {
                        return DropdownMenuItem(
                          value: skill,
                          child: Text(BlogService.getSkillName(skill)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value ?? 'all';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Posts list
            if (_filteredPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: AppColors.primaryWhite.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có bài viết',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryWhite.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy tạo bài viết đầu tiên của bạn!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryWhite.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/blog/create'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlack,
                      ),
                      child: const Text('Tạo bài viết mới'),
                    ),
                  ],
                ),
              )
            else
              ..._filteredPosts.map((post) => _buildPostCard(post)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blackMedium,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryYellow.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryYellow, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryYellow,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primaryWhite.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BlogPost post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blackMedium,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryYellow.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primaryYellow),
                onPressed: () {
                  // Navigate to edit screen
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.blackMedium,
                      title: const Text(
                        'Xóa bài viết?',
                        style: TextStyle(color: AppColors.primaryWhite),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () {
                            BlogService.deletePost(post.id);
                            _loadPosts();
                            Navigator.pop(context);
                          },
                          child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryWhite),
              const SizedBox(width: 4),
              Text(
                _formatDate(post.date),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryWhite.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.visibility, size: 14, color: AppColors.primaryWhite),
              const SizedBox(width: 4),
              Text(
                '${post.views} lượt xem',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryWhite.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: post.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryYellow.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryYellow,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

