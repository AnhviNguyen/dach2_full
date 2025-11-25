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

  factory LearningMaterial.fromJson(Map<String, dynamic> json) {
    return LearningMaterial(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: json['level'] as String? ?? 'beginner',
      skill: json['skill'] as String? ?? 'vocabulary',
      type: json['type'] as String? ?? 'pdf',
      thumbnail: json['thumbnail'] as String? ?? '📚',
      downloads: json['downloads'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      size: json['size'] as String? ?? '0 MB',
      points: json['points'] as int? ?? 0,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      duration: json['duration'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }
}

