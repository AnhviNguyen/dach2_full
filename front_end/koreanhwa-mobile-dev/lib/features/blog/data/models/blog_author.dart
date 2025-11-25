class BlogAuthor {
  final String name;
  final String avatar;
  final String level;

  BlogAuthor({
    required this.name,
    required this.avatar,
    required this.level,
  });

  factory BlogAuthor.fromJson(Map<String, dynamic> json) {
    return BlogAuthor(
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      level: json['level'] as String? ?? '',
    );
  }
}

