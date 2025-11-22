import 'package:koreanhwa_flutter/features/blog/data/models/blog_author.dart';

class BlogComment {
  final int id;
  final BlogAuthor author;
  final String content;
  final DateTime date;
  final int likes;
  final bool isLiked;

  BlogComment({
    required this.id,
    required this.author,
    required this.content,
    required this.date,
    required this.likes,
    required this.isLiked,
  });
}

