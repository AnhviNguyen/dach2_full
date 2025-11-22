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

