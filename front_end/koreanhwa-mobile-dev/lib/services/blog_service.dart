import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/blog_model.dart';

class BlogService {
  static List<BlogPost> _posts = [
    BlogPost(
      id: 1,
      title: 'Cách học từ vựng hiệu quả cho người mới bắt đầu',
      content: 'Học từ vựng tiếng Hàn có thể là một thách thức lớn đối với người mới bắt đầu. Trong bài viết này, tôi sẽ chia sẻ những phương pháp học từ vựng hiệu quả mà tôi đã áp dụng...',
      author: BlogAuthor(name: 'Nguyễn Thị Anh', avatar: 'A', level: 'Trung cấp 1'),
      skill: 'vocabulary',
      likes: 45,
      comments: 12,
      views: 234,
      date: DateTime(2024, 1, 20),
      tags: ['từ vựng', 'học tập', 'kinh nghiệm'],
      isLiked: false,
      isMyPost: false,
    ),
    BlogPost(
      id: 2,
      title: 'Kinh nghiệm luyện nghe TOPIK I',
      content: 'Sau khi thi đạt TOPIK I với điểm số 180/200, tôi muốn chia sẻ những kinh nghiệm luyện nghe hiệu quả. Điều quan trọng nhất là phải luyện tập thường xuyên...',
      author: BlogAuthor(name: 'Lê Văn Bình', avatar: 'B', level: 'Sơ cấp 3'),
      skill: 'listening',
      likes: 67,
      comments: 23,
      views: 456,
      date: DateTime(2024, 1, 19),
      tags: ['TOPIK', 'luyện nghe', 'kinh nghiệm'],
      isLiked: true,
      isMyPost: false,
    ),
    BlogPost(
      id: 3,
      title: 'Phương pháp học ngữ pháp tiếng Hàn',
      content: 'Ngữ pháp tiếng Hàn có thể phức tạp, nhưng với phương pháp đúng, bạn có thể nắm vững nhanh chóng. Tôi sẽ chia sẻ cách học ngữ pháp hiệu quả...',
      author: BlogAuthor(name: 'Trần Minh Cường', avatar: 'C', level: 'Trung cấp 2'),
      skill: 'grammar',
      likes: 34,
      comments: 8,
      views: 189,
      date: DateTime(2024, 1, 18),
      tags: ['ngữ pháp', 'học tập'],
      isLiked: false,
      isMyPost: true,
    ),
    BlogPost(
      id: 4,
      title: 'Cách luyện phát âm chuẩn như người Hàn',
      content: 'Phát âm là một trong những kỹ năng quan trọng nhất khi học tiếng Hàn. Trong bài viết này, tôi sẽ hướng dẫn cách luyện phát âm chuẩn...',
      author: BlogAuthor(name: 'Phạm Thị Dung', avatar: 'D', level: 'Sơ cấp 2'),
      skill: 'speaking',
      likes: 89,
      comments: 31,
      views: 567,
      date: DateTime(2024, 1, 17),
      tags: ['phát âm', 'nói', 'kinh nghiệm'],
      isLiked: false,
      isMyPost: false,
    ),
  ];

  static List<BlogPost> getPosts({
    String? searchQuery,
    String? skill,
    String? tab, // 'all', 'my', 'favorites'
  }) {
    var filtered = _posts;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((post) {
        return post.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            post.content.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (skill != null && skill != 'all') {
      filtered = filtered.where((post) => post.skill == skill).toList();
    }

    if (tab != null) {
      if (tab == 'my') {
        filtered = filtered.where((post) => post.isMyPost).toList();
      } else if (tab == 'favorites') {
        filtered = filtered.where((post) => post.isLiked).toList();
      }
    }

    return filtered;
  }

  static BlogPost? getPostById(int id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  static void addPost(BlogPost post) {
    _posts.insert(0, post);
  }

  static void deletePost(int id) {
    _posts.removeWhere((post) => post.id == id);
  }

  static void updatePost(BlogPost updatedPost) {
    final index = _posts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
    }
  }

  static void toggleLike(int postId) {
    final post = getPostById(postId);
    if (post != null) {
      final updatedPost = post.copyWith(
        isLiked: !post.isLiked,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
      );
      updatePost(updatedPost);
    }
  }

  static List<String> getSkills() {
    return ['all', 'listening', 'speaking', 'reading', 'writing', 'vocabulary', 'grammar'];
  }

  static String getSkillName(String skillId) {
    switch (skillId) {
      case 'listening':
        return 'Nghe';
      case 'speaking':
        return 'Nói';
      case 'reading':
        return 'Đọc';
      case 'writing':
        return 'Viết';
      case 'vocabulary':
        return 'Từ vựng';
      case 'grammar':
        return 'Ngữ pháp';
      default:
        return 'Tất cả kỹ năng';
    }
  }

  static IconData getSkillIcon(String skill) {
    switch (skill) {
      case 'listening':
        return Icons.headphones;
      case 'speaking':
        return Icons.mic;
      case 'reading':
        return Icons.menu_book;
      case 'writing':
        return Icons.edit;
      case 'vocabulary':
        return Icons.book;
      case 'grammar':
        return Icons.book;
      default:
        return Icons.article;
    }
  }
}

