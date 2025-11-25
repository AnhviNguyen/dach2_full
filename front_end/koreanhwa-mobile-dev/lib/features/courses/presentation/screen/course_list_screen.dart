import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koreanhwa_flutter/features/courses/presentation/screen/course_detail_screen.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/courses/data/services/course_api_service.dart';
import 'package:koreanhwa_flutter/features/courses/data/models/course_info.dart';
import 'package:koreanhwa_flutter/features/courses/data/models/dashboard_stats.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  final String title;

  const CourseListScreen({
    super.key,
    this.title = 'Khóa học của tôi',
  });

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  final CourseApiService _courseApiService = CourseApiService();
  List<CourseInfo> _courses = [];
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;

      final coursesFuture = _courseApiService.getAllCourses();
      final statsFuture = _courseApiService.getDashboardStats(userId: userId);

      final results = await Future.wait([coursesFuture, statsFuture]);

      setState(() {
        _courses = results[0] as List<CourseInfo>;
        _stats = results[1] as DashboardStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBEB),
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lỗi: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 12),
                        _buildNoticeCard(),
                        const SizedBox(height: 16),
                        if (_stats != null) ...[
                          _buildStatsGrid(),
                          const SizedBox(height: 12),
                          _buildProgressRing(),
                          const SizedBox(height: 16),
                          _buildVideoStats(),
                        ],
                        const SizedBox(height: 20),
                        _buildCourseList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlack.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khóa học của tôi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Theo dõi tiến độ học tập và truy cập các khóa học bạn đã đăng ký.',
            style: TextStyle(
              color: AppColors.primaryBlack.withOpacity(0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primaryYellow,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dữ liệu có thể mất 1-2 phút để cập nhật!',
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    if (_courses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Chưa có khóa học nào'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh sách khóa học',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 12),
        ..._courses.map((course) => _buildCourseCard(course)),
      ],
    );
  }

  Widget _buildCourseCard(CourseInfo course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(course.title),
        subtitle: Text('${course.level} • ${course.lessons} bài học'),
        trailing: course.isEnrolled
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.add_circle_outline),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(
                courseTitle: course.title,
                instructorName: course.instructor,
                price: _parsePrice(course.price),
                originalPrice: _parsePrice(course.price) * 1.3,
                discount: 24,
                rating: course.rating,
                reviewCount: 0,
                lessonCount: course.lessons,
                studentCount: course.students,
                daysAccess: 90,
              ),
            ),
          );
        },
      ),
    );
  }

  double _parsePrice(String priceStr) {
    try {
      // Remove currency symbols and parse
      final cleaned = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        _StatTile(
          icon: Icons.menu_book,
          title: 'Số khóa học',
          value: '${_stats!.totalCourses}',
          progressLabel: '${_stats!.completedCourses}/${_stats!.totalCourses}',
          progress: _stats!.totalCourses == 0
              ? 0
              : _stats!.completedCourses / _stats!.totalCourses,
        ),
        const SizedBox(height: 10),
        _StatTile(
          icon: Icons.play_circle_fill,
          title: 'Video bài giảng',
          value: '${_stats!.totalVideos}',
          progressLabel: '${_stats!.watchedVideos}/${_stats!.totalVideos}',
          progress: _stats!.totalVideos == 0
              ? 0
              : _stats!.watchedVideos / _stats!.totalVideos,
        ),
        const SizedBox(height: 10),
        _StatTile(
          icon: Icons.quiz_outlined,
          title: 'Số đề thi',
          value: '${_stats!.totalExams}',
          progressLabel: '${_stats!.completedExams}/${_stats!.totalExams}',
          progress: _stats!.totalExams == 0
              ? 0
              : _stats!.completedExams / _stats!.totalExams,
        ),
      ],
    );
  }

  Widget _buildProgressRing() {
    if (_stats == null) return const SizedBox.shrink();
    
    return _StatDonut(
      label: 'Tiến độ',
      percent: _stats!.completedCourses == 0
          ? 0.032
          : _stats!.completedCourses / (_stats!.totalCourses == 0 ? 1 : _stats!.totalCourses),
    );
  }

  Widget _buildVideoStats() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlack.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thống kê nhanh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(label: 'Hoàn thành', color: AppColors.primaryYellow),
                  _Chip(label: 'Chưa hoàn thành', color: Colors.grey.shade400),
                  _Chip(label: 'Sắp hết hạn', color: Colors.red.shade300),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _InfoCard(
          icon: Icons.schedule,
          title: 'Tổng thời lượng video',
          value: _stats?.totalWatchTime ?? '0:00:00',
          accent: AppColors.primaryYellow,
        ),
        const SizedBox(height: 10),
        _InfoCard(
          icon: Icons.access_time_filled,
          title: 'Truy cập gần nhất',
          value: _stats?.lastAccess ?? 'Chưa có',
          accent: AppColors.primaryBlack,
          secondary: _stats?.endDate,
        ),
      ],
    );
  }

  Widget _buildCourseSection(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlack.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 3,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text(
                  'Xem thêm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.primaryBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._courses.map((course) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCourseCard(course),
          )),
        ],
      ),
    );
  }

  Widget _buildCourseTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlack.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              'Danh sách khóa học',
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ..._courses.asMap().entries.map((entry) {
            final course = entry.value;
            final isEven = entry.key % 2 == 0;
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(
                      courseTitle: course.title,
                      instructorName: course.instructor,
                      price: _parsePrice(course.price),
                      originalPrice: _parsePrice(course.price) * 1.3,
                      discount: 24,
                      rating: course.rating,
                      reviewCount: 0,
                      lessonCount: course.lessons,
                      studentCount: course.students,
                      daysAccess: 90,
                    ),
                  ),
                );
              },
              child: Container(
                color: isEven ? Colors.white : const Color(0xFFFFF7E5),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${course.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlack,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: const TextStyle(
                                  color: AppColors.primaryBlack,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                course.level,
                                style: const TextStyle(
                                  color: AppColors.primaryYellow,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _TableInfo(
                          label: 'Bài học',
                          value: '${course.lessons}',
                        ),
                        _TableInfo(
                          label: 'Tiến độ',
                          value: '${(course.progress * 100).toStringAsFixed(0)}%',
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                course.isEnrolled ? 'Đã đăng ký' : 'Chưa đăng ký',
                                style: TextStyle(
                                  color: course.isEnrolled ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

}

class _TableInfo extends StatelessWidget {
  final String label;
  final String value;

  const _TableInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}


class _DashboardStats {
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

  const _DashboardStats({
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

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String progressLabel;
  final double progress;

  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.progressLabel,
    this.progress = 0.01,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryBlack, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlack,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(AppColors.primaryYellow),
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressLabel,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatDonut extends StatelessWidget {
  final String label;
  final double percent;

  const _StatDonut({
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final value = (percent * 100).clamp(0, 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryYellow),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$value%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Bạn đã hoàn thành',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? AppColors.primaryBlack : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accent;
  final String? secondary;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (secondary != null)
                  Text(
                    secondary!,
                    style: const TextStyle(
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
