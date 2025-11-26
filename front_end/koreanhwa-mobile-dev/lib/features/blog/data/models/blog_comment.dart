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

  factory BlogComment.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      } else if (dateValue is Map) {
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

    return BlogComment(
      id: json['id'] as int,
      author: BlogAuthor.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String? ?? '',
      date: parseDate(json['date']),
      likes: json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }
}

