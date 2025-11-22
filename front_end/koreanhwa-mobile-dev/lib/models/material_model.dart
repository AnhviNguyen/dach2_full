class LearningMaterial {
  final int id;
  final String title;
  final String description;
  final String type;
  final String skill;
  final String level;
  final int points;
  final int downloads;
  final double rating;
  final String size;
  final String? duration;
  final String thumbnail;
  final bool isDownloaded;
  final bool isFeatured;
  final String? pdfUrl;

  LearningMaterial({  // Đổi từ Material thành LearningMaterial
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.skill,
    required this.level,
    required this.points,
    required this.downloads,
    required this.rating,
    required this.size,
    this.duration,
    required this.thumbnail,
    required this.isDownloaded,
    required this.isFeatured,
    this.pdfUrl,
  });
}