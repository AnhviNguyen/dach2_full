import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/blog/data/models/blog_post.dart';
import 'package:koreanhwa_flutter/features/blog/data/models/blog_comment.dart';
import 'package:koreanhwa_flutter/features/blog/data/services/blog_api_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class BlogDetailScreen extends ConsumerStatefulWidget {
  final int? postId;
  final BlogPost? post;

  const BlogDetailScreen({super.key, this.postId, this.post});

  @override
  ConsumerState<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends ConsumerState<BlogDetailScreen> {
  BlogPost? _post;
  List<BlogComment> _comments = [];
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 0;
  int _viewCount = 0;
  bool _isLoading = false;
  bool _isLoadingComments = false;
  final BlogApiService _blogApiService = BlogApiService();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    if (_post != null) {
      _isLiked = _post!.isLiked;
      _likeCount = _post!.likes;
      _viewCount = _post!.views;
      _isInitialLoad = true;
      _loadComments();
      _incrementView();
    } else if (widget.postId != null) {
      _isInitialLoad = true;
      _loadPost(widget.postId!);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool _isInitialLoad = true;

  Future<void> _loadPost(int id) async {
    final userId = ref.read(authProvider).user?.id;
    setState(() => _isLoading = true);
    try {
      final post = await _blogApiService.getPostById(id, currentUserId: userId);
      setState(() {
        _post = post;
        if (post != null) {
          _isLiked = post.isLiked;
          _likeCount = post.likes;
          _viewCount = post.views;
        }
        _isLoading = false;
      });
      _loadComments();
      // Only increment view on initial load
      if (_isInitialLoad) {
        _incrementView();
        _isInitialLoad = false;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bài viết: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _reloadPost() async {
    if (_post == null) return;
    final userId = ref.read(authProvider).user?.id;
    try {
      final post = await _blogApiService.getPostById(_post!.id, currentUserId: userId);
      setState(() {
        _post = post;
        if (post != null) {
          _isLiked = post.isLiked;
          _likeCount = post.likes;
          _viewCount = post.views;
        }
      });
    } catch (e) {
      // Silently fail - reload is not critical
    }
  }

  Future<void> _loadComments() async {
    if (_post == null) return;
    setState(() => _isLoadingComments = true);
    try {
      final userId = ref.read(authProvider).user?.id;
      final comments = await _blogApiService.getComments(_post!.id, currentUserId: userId);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _incrementView() async {
    if (_post == null) return;
    try {
      await _blogApiService.incrementView(_post!.id);
      setState(() {
        _viewCount++;
      });
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;
    
    try {
      final updatedPost = await _blogApiService.toggleLike(_post!.id, userId);
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

  Future<void> _submitComment() async {
    if (_post == null || _commentController.text.trim().isEmpty) return;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để bình luận')),
      );
      return;
    }

    try {
      final comment = await _blogApiService.createComment(
        _post!.id,
        userId,
        _commentController.text.trim(),
      );
      
      // Reload post to get updated comment count from backend
      await _reloadPost();
      
      // Reload comments to get the new comment in the list
      await _loadComments();
      
      // Clear comment input
      setState(() {
        _commentController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  List<ContentBlock> _parseContent(String content) {
    final blocks = <ContentBlock>[];
    
    // Split content by image markers: [IMAGE: path]
    final imagePattern = RegExp(r'\[IMAGE:\s*([^\]]+)\]');
    final matches = imagePattern.allMatches(content);
    
    if (matches.isEmpty) {
      // No images, just parse text
      _parseTextContent(content, blocks);
      return blocks;
    }
    
    // Process content with images
    int lastEnd = 0;
    for (final match in matches) {
      // Add text before image
      if (match.start > lastEnd) {
        final textBefore = content.substring(lastEnd, match.start).trim();
        if (textBefore.isNotEmpty) {
          _parseTextContent(textBefore, blocks);
        }
      }
      
      // Add image
      final imagePath = match.group(1)?.trim() ?? '';
      if (imagePath.isNotEmpty) {
        blocks.add(ContentBlock(type: 'image', content: imagePath));
      }
      
      lastEnd = match.end;
    }
    
    // Add remaining text after last image
    if (lastEnd < content.length) {
      final textAfter = content.substring(lastEnd).trim();
      if (textAfter.isNotEmpty) {
        _parseTextContent(textAfter, blocks);
      }
    }
    
    return blocks;
  }

  void _parseTextContent(String text, List<ContentBlock> blocks) {
    // Split by paragraphs (double newlines or single newline)
    final paragraphs = text.split(RegExp(r'\n\s*\n|\n'));
    
    for (final paragraph in paragraphs) {
      final trimmed = paragraph.trim();
      if (trimmed.isEmpty) continue;
      
      // Check for style markers in the paragraph
      // Note: blog_create_screen doesn't save style markers in content,
      // so we can't restore them. But we can still display the text.
      blocks.add(ContentBlock(
        type: 'text',
        content: trimmed,
        style: {},
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đang tải...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bài viết không tồn tại')),
        body: const Center(child: Text('Bài viết không tồn tại')),
      );
    }

    final contentBlocks = _parseContent(_post!.content);

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: CustomScrollView(
        slivers: [
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
          if (_post!.featuredImage != null)
            SliverToBoxAdapter(
              child: Container(
                height: 250,
                width: double.infinity,
                child: _post!.featuredImage!.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: _post!.featuredImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.primaryYellow.withOpacity(0.2),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.primaryYellow.withOpacity(0.2),
                          child: const Icon(Icons.image, size: 50),
                        ),
                      )
                    : Image.file(
                        File(_post!.featuredImage!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primaryYellow.withOpacity(0.2),
                          child: const Icon(Icons.image, size: 50),
                        ),
                      ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _post!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      const Icon(Icons.visibility, size: 16, color: AppColors.primaryYellow),
                      const SizedBox(width: 4),
                      Text(
                        '$_viewCount lượt xem',
                        style: TextStyle(
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                        Icons.comment,
                        _post!.comments.toString(),
                        false,
                        () {},
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        Icons.bookmark,
                        '',
                        _isBookmarked,
                        () => setState(() => _isBookmarked = !_isBookmarked),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // Content blocks
                  ...contentBlocks.map((block) {
                    if (block.type == 'image') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: block.content.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: block.content,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(
                                    height: 200,
                                    color: AppColors.primaryYellow.withOpacity(0.2),
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 200,
                                    color: AppColors.primaryYellow.withOpacity(0.2),
                                    child: const Icon(Icons.image, size: 50),
                                  ),
                                )
                              : Image.file(
                                  File(block.content),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 200,
                                    color: AppColors.primaryYellow.withOpacity(0.2),
                                    child: const Icon(Icons.image, size: 50),
                                  ),
                                ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRichText(block.content),
                      );
                    }
                  }).toList(),
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
                          child: _post!.author.avatar.startsWith('http')
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: _post!.author.avatar,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Text(
                                      _post!.author.name.isNotEmpty ? _post!.author.name[0].toUpperCase() : 'A',
                                      style: const TextStyle(
                                        color: AppColors.primaryBlack,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  _post!.author.avatar.isNotEmpty ? _post!.author.avatar : (_post!.author.name.isNotEmpty ? _post!.author.name[0].toUpperCase() : 'A'),
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
                                _post!.author.level,
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
                  // Comments section
                  const Text(
                    'Bình luận',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Comment input
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteGray,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlack.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Viết bình luận...',
                              border: InputBorder.none,
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _submitComment,
                          icon: const Icon(Icons.send, color: AppColors.primaryYellow),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Comments list
                  _isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : _comments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'Chưa có bình luận nào',
                                  style: TextStyle(
                                    color: AppColors.primaryBlack.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: _comments.map((comment) => _buildCommentCard(comment)).toList(),
                            ),
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

  Widget _buildCommentCard(BlogComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryYellow,
                child: comment.author.avatar.startsWith('http')
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: comment.author.avatar,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Text(
                            comment.author.name.isNotEmpty ? comment.author.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: AppColors.primaryBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        comment.author.avatar.isNotEmpty ? comment.author.avatar : (comment.author.name.isNotEmpty ? comment.author.name[0].toUpperCase() : 'U'),
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
                      comment.author.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(comment.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  comment.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: comment.isLiked ? Colors.red : AppColors.grayLight,
                  size: 20,
                ),
                onPressed: () {},
              ),
              Text(
                '${comment.likes}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryBlack.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichText(String text) {
    // Parse text for inline styles: **bold**, *italic*, __underline__
    final List<InlineSpan> spans = [];
    final RegExp styleRegex = RegExp(r'(\*\*(.*?)\*\*)|(\*(.*?)\*)|(__(.*?)__)');
    
    int lastMatchEnd = 0;
    final matches = styleRegex.allMatches(text);
    
    for (final match in matches) {
      // Add text before match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: const TextStyle(
            fontSize: 16,
            height: 1.7,
            color: AppColors.primaryBlack,
          ),
        ));
      }
      
      // Add styled text
      TextStyle style = const TextStyle(
        fontSize: 16,
        height: 1.7,
        color: AppColors.primaryBlack,
      );
      String? styledText;
      
      if (match.group(1) != null) {
        // Bold: **text**
        styledText = match.group(2);
        style = style.copyWith(fontWeight: FontWeight.bold);
      } else if (match.group(3) != null) {
        // Italic: *text*
        styledText = match.group(4);
        style = style.copyWith(fontStyle: FontStyle.italic);
      } else if (match.group(5) != null) {
        // Underline: __text__
        styledText = match.group(6);
        style = style.copyWith(decoration: TextDecoration.underline);
      }
      
      if (styledText != null) {
        spans.add(TextSpan(text: styledText, style: style));
      }
      
      lastMatchEnd = match.end;
    }
    
    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: AppColors.primaryBlack,
        ),
      ));
    }
    
    // If no matches found, return plain text
    if (spans.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: AppColors.primaryBlack,
        ),
      );
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: AppColors.primaryBlack,
        ),
        children: spans,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class ContentBlock {
  final String type;
  final String content;
  final Map<String, dynamic> style;

  ContentBlock({
    required this.type,
    required this.content,
    Map<String, dynamic>? style,
  }) : style = style ?? {};
}
