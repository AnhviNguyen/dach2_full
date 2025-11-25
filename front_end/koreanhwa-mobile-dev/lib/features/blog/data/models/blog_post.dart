import 'package:koreanhwa_flutter/features/blog/data/models/blog_author.dart';

class BlogPost {
  final int id;
  final String title;
  final String content;
  final BlogAuthor author;
  final String skill;
  final int likes;
  final int comments;
  final int views;
  final DateTime date;
  final List<String> tags;
  final bool isLiked;
  final bool isMyPost;
  final String? featuredImage;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.skill,
    required this.likes,
    required this.comments,
    required this.views,
    required this.date,
    required this.tags,
    required this.isLiked,
    required this.isMyPost,
    this.featuredImage,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      } else if (dateValue is Map) {
        // Handle LocalDateTime from Java
        try {
          final year = dateValue['year'] as int? ?? DateTime.now().year;
          final month = dateValue['monthValue'] as int? ?? DateTime.now().month;
          final day = dateValue['dayOfMonth'] as int? ?? DateTime.now().day;
          final hour = dateValue['hour'] as int? ?? 0;
          final minute = dateValue['minute'] as int? ?? 0;
          final second = dateValue['second'] as int? ?? 0;
          return DateTime(year, month, day, hour, minute, second);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return BlogPost(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: BlogAuthor.fromJson(json['author'] as Map<String, dynamic>),
      skill: json['skill'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      date: parseDate(json['date']),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      isLiked: json['isLiked'] as bool? ?? false,
      isMyPost: json['isMyPost'] as bool? ?? false,
      featuredImage: json['featuredImage'] as String?,
    );
  }

  BlogPost copyWith({
    int? id,
    String? title,
    String? content,
    BlogAuthor? author,
    String? skill,
    int? likes,
    int? comments,
    int? views,
    DateTime? date,
    List<String>? tags,
    bool? isLiked,
    bool? isMyPost,
    String? featuredImage,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      skill: skill ?? this.skill,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      views: views ?? this.views,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      isLiked: isLiked ?? this.isLiked,
      isMyPost: isMyPost ?? this.isMyPost,
      featuredImage: featuredImage ?? this.featuredImage,
    );
  }
}

