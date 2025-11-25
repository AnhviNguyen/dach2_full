import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/services/blog_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/blog/data/models/blog_post.dart';
import 'package:koreanhwa_flutter/features/blog/presentation/widgets/blog_stat_card.dart';
import 'package:koreanhwa_flutter/features/blog/presentation/widgets/blog_tab_button.dart';
import 'package:koreanhwa_flutter/features/blog/presentation/widgets/blog_post_card.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';

class BlogScreen extends ConsumerStatefulWidget {
  const BlogScreen({super.key});

  @override
  ConsumerState<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends ConsumerState<BlogScreen> {
  String _activeTab = 'all';
  String _selectedSkill = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final BlogService _blogService = BlogService();
  List<BlogPost> _allPosts = [];
  List<BlogPost> _myPosts = [];
  List<BlogPost> _favoritePosts = [];
  List<BlogPost> _filteredPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final all = await _blogService.getPosts(currentUserId: userId);
      final my = await _blogService.getPostsByAuthor(userId);
      final favorites = await _blogService.getPosts(currentUserId: userId);
      
      setState(() {
        _allPosts = all;
        _myPosts = my.content;
        _favoritePosts = favorites.where((p) => p.isLiked).toList();
        _updateFilteredPosts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: ${e.toString()}')),
        );
      }
    }
  }

  void _updateFilteredPosts() {
    List<BlogPost> baseList;
    switch (_activeTab) {
      case 'my':
        baseList = _myPosts;
        break;
      case 'favorites':
        baseList = _favoritePosts;
        break;
      default:
        baseList = _allPosts;
    }

    var filtered = baseList;

    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((post) {
        return post.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            post.content.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }

    if (_selectedSkill != 'all') {
      filtered = filtered.where((post) => post.skill == _selectedSkill).toList();
    }

    setState(() {
      _filteredPosts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryWhite,
        appBar: AppBar(
          backgroundColor: AppColors.primaryWhite,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          ),
          title: const Text(
            'Blog học viên',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blog học viên',
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Chia sẻ kinh nghiệm học tập và kết nối với cộng đồng',
              style: TextStyle(
                color: AppColors.primaryBlack.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/blog/create'),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Tạo bài viết',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: BlogStatCard(
                      icon: Icons.article,
                      value: '${_allPosts.length}',
                      label: 'Tổng bài viết',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlogStatCard(
                      icon: Icons.person,
                      value: '${_myPosts.length}',
                      label: 'Bài viết của tôi',
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlogStatCard(
                      icon: Icons.favorite,
                      value: '${_favoritePosts.length}',
                      label: 'Bài yêu thích',
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlogStatCard(
                      icon: Icons.visibility,
                      value: '1,446',
                      label: 'Lượt xem bài viết',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: BlogTabButton(
                      label: 'Tất cả bài viết',
                      value: 'all',
                      isSelected: _activeTab == 'all',
                      onTap: () {
                        setState(() => _activeTab = 'all');
                        _updateFilteredPosts();
                      },
                    ),
                  ),
                  Expanded(
                    child: BlogTabButton(
                      label: 'Bài viết của tôi',
                      value: 'my',
                      isSelected: _activeTab == 'my',
                      onTap: () {
                        setState(() => _activeTab = 'my');
                        _updateFilteredPosts();
                      },
                    ),
                  ),
                  Expanded(
                    child: BlogTabButton(
                      label: 'Yêu thích',
                      value: 'favorites',
                      isSelected: _activeTab == 'favorites',
                      onTap: () {
                        setState(() => _activeTab = 'favorites');
                        _updateFilteredPosts();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm bài viết...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.primaryWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlack.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlack.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryYellow,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (_) => _updateFilteredPosts(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSkill,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.filter_list, color: AppColors.primaryWhite),
                      dropdownColor: AppColors.primaryWhite,
                      style: const TextStyle(color: AppColors.primaryBlack),
                      items: BlogService.getSkills().map((skill) {
                        return DropdownMenuItem(
                          value: skill,
                          child: Text(BlogService.getSkillName(skill)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSkill = value ?? 'all';
                        });
                        _updateFilteredPosts();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_filteredPosts.isEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: AppColors.primaryBlack.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy bài viết',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryBlack.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thử thay đổi bộ lọc hoặc tạo bài viết đầu tiên',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._filteredPosts.map((post) => BlogPostCard(post: post)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryBlack.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quản lý Blog Của Bạn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildManagementCard(
                            Icons.edit,
                            '${_myPosts.length}',
                            'Bài viết',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildManagementCard(
                            Icons.thumb_up,
                            '145',
                            'Lượt thích',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildManagementCard(
                            Icons.visibility,
                            '1,234',
                            'Lượt xem',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/blog/manage'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlack,
                          foregroundColor: AppColors.primaryWhite,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Xem chi tiết quản lý',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlack, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryBlack.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

