class DashboardStats {
  final int totalCourses;
  final int completedCourses;
  final int totalVideos;
  final int watchedVideos;
  final int totalExams;
  final int completedExams;
  final String totalWatchTime;
  final String completedWatchTime;
  final String lastAccess;
  final String endDate;

  const DashboardStats({
    required this.totalCourses,
    required this.completedCourses,
    required this.totalVideos,
    required this.watchedVideos,
    required this.totalExams,
    required this.completedExams,
    required this.totalWatchTime,
    required this.completedWatchTime,
    required this.lastAccess,
    required this.endDate,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCourses: json['totalCourses'] as int? ?? 0,
      completedCourses: json['completedCourses'] as int? ?? 0,
      totalVideos: json['totalVideos'] as int? ?? 0,
      watchedVideos: json['watchedVideos'] as int? ?? 0,
      totalExams: json['totalExams'] as int? ?? 0,
      completedExams: json['completedExams'] as int? ?? 0,
      totalWatchTime: json['totalWatchTime'] as String? ?? '',
      completedWatchTime: json['completedWatchTime'] as String? ?? '',
      lastAccess: json['lastAccess'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
    );
  }
}

