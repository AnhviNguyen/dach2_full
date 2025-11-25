import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/blog/data/models/blog_post.dart';
import 'package:koreanhwa_flutter/services/blog_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';

class BlogDetailScreen extends ConsumerStatefulWidget {
  final BlogPost? post;

  const BlogDetailScreen({super.key, this.post});

  @override
  ConsumerState<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends ConsumerState<BlogDetailScreen> {
  BlogPost? _post;
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 0;
  bool _isLoading = false;
  final BlogService _blogService = BlogService();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    if (_post != null) {
      _isLiked = _post!.isLiked;
      _likeCount = _post!.likes;
    } else {
      _loadPost(1);
    }
  }

  Future<void> _loadPost(int id) async {
    final userId = ref.read(authProvider).user?.id;
    setState(() => _isLoading = true);
    try {
      final post = await _blogService.getPostById(id, currentUserId: userId);
      setState(() {
        _post = post;
        if (post != null) {
          _isLiked = post.isLiked;
          _likeCount = post.likes;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bài viết: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_post != null) {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) return;
      
      try {
        final updatedPost = await _blogService.toggleLike(_post!.id, userId);
        setState(() {
          _post = updatedPost;
          _isLiked = updatedPost.isLiked;
          _likeCount = updatedPost.likes;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bài viết không tồn tại')),
        body: const Center(child: Text('Bài viết không tồn tại')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryBlack,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryWhite),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Chi tiết bài viết',
              style: TextStyle(color: AppColors.primaryWhite),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.primaryWhite),
                onPressed: () {},
              ),
            ],
          ),
          // Hero Image
          if (_post!.featuredImage != null)
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryYellow,
                      AppColors.primaryYellow.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 12,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          BlogService.getSkillName(_post!.skill),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _post!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Meta info
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AppColors.primaryYellow),
                      const SizedBox(width: 4),
                      Text(
                        _post!.author.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryYellow),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(_post!.date),
                        style: TextStyle(
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 16, color: AppColors.primaryYellow),
                      const SizedBox(width: 4),
                      Text(
                        '8 phút đọc',
                        style: TextStyle(
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      _buildActionButton(
                        Icons.favorite,
                        _likeCount.toString(),
                        _isLiked,
                        _toggleLike,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        Icons.bookmark,
                        '',
                        _isBookmarked,
                        () => setState(() => _isBookmarked = !_isBookmarked),
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        Icons.comment,
                        _post!.comments.toString(),
                        false,
                        () {},
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Theo dõi'),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // Content
                  Text(
                    _post!.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Author card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryYellow.withOpacity(0.2),
                          AppColors.primaryWhite,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryYellow,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryYellow,
                          child: Text(
                            _post!.author.avatar,
                            style: const TextStyle(
                              color: AppColors.primaryBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _post!.author.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                              Text(
                                'Tác giả & Chuyên gia',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryBlack.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Related articles
                  const Text(
                    'Bài viết liên quan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(3, (index) => _buildRelatedArticleCard(index)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryYellow : AppColors.whiteGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primaryBlack : AppColors.primaryBlack.withOpacity(0.6),
            ),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.primaryBlack : AppColors.primaryBlack.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedArticleCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryYellow, AppColors.yellowDark],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bài viết mẫu số ${index + 1}: Tiêu đề dài để test',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primaryBlack,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mô tả ngắn về bài viết để người đọc biết nội dung...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlack.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.grayLight),
                    const SizedBox(width: 4),
                    Text(
                      '5 phút đọc',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} Tháng ${date.month}, ${date.year}';
  }
}

