class LearningMaterial {
  final int id;
  final String title;
  final String description;
  final String level; // 'beginner', 'intermediate', 'advanced'
  final String skill; // 'listening', 'speaking', 'reading', 'writing', 'vocabulary', 'grammar'
  final String type; // 'pdf', 'video', 'audio', 'lesson'
  final String thumbnail;
  final int downloads;
  final double rating;
  final String size;
  final int points;
  final bool isDownloaded;
  final bool isFeatured;
  final String? duration;
  final String? pdfUrl;
  final String? videoUrl;
  final String? audioUrl;

  LearningMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.skill,
    required this.type,
    required this.thumbnail,
    required this.downloads,
    required this.rating,
    required this.size,
    required this.points,
    required this.isDownloaded,
    required this.isFeatured,
    this.duration,
    this.pdfUrl,
    this.videoUrl,
    this.audioUrl,
  });
}

