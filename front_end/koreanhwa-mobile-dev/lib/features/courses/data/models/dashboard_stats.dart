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
}

