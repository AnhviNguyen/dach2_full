import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class CourseClassroomScreen extends StatefulWidget {
  final String courseTitle;

  const CourseClassroomScreen({
    super.key,
    required this.courseTitle,
  });

  @override
  State<CourseClassroomScreen> createState() => _CourseClassroomScreenState();
}

class _CourseClassroomScreenState extends State<CourseClassroomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSummary(),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryYellow,
              labelColor: AppColors.primaryBlack,
              tabs: const [
                Tab(text: 'Nội dung'),
                Tab(text: 'Đánh giá'),
                Tab(text: 'Học viên'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ContentTab(onOpenLesson: _openCurriculum),
                const _ReviewsTab(),
                const _StudentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFECECEC)),
          bottom: BorderSide(color: Color(0xFFECECEC)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '[-24%] COMBO TOPIK II + MockTest',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Thời gian học: 2025-06-25 ~ 2025-09-23 (90 ngày)'),
                Text('Tổng thời lượng bài giảng: 144:1:32'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Tiến độ', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: 0.04,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryYellow),
                ),
              ),
              const SizedBox(height: 4),
              const Text('4%', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _openCurriculum() {
    final encodedTitle = Uri.encodeComponent(widget.courseTitle);
    context.push('/learning-curriculum?bookId=1&lessonId=1&bookTitle=$encodedTitle');
  }
}

class _ContentTab extends StatelessWidget {
  final VoidCallback onOpenLesson;

  const _ContentTab({required this.onOpenLesson});

  @override
  Widget build(BuildContext context) {
    final lessons = [
      ('Giới thiệu khóa học', '00:02:26', true),
      ('[Bài 1] Chọn ngữ pháp đúng [1-2]', '00:18:04', false),
      ('[Bài 2] Chọn ngữ pháp tương tự [3-4]', '00:15:18', false),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...lessons.map(
          (lesson) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  lesson.$3 ? Icons.check_circle : Icons.play_circle,
                  color: lesson.$3 ? Colors.green : AppColors.primaryYellow,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thời lượng: ${lesson.$2}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onOpenLesson,
                  child: const Text('Học ngay'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    final reviews = [
      ('Nguyễn Văn A', 5, 'Khóa học rất hay, giảng viên nhiệt tình!'),
      ('Trần Thị B', 5, 'Nội dung phong phú, bài tập hữu ích.'),
      ('Lê Minh C', 4, 'Muốn có thêm nhiều bài tập thực hành.'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Viết đánh giá của bạn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Chia sẻ trải nghiệm của bạn...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryYellow,
            foregroundColor: AppColors.primaryBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Gửi đánh giá'),
        ),
        const SizedBox(height: 24),
        ...reviews.map(
          (item) => Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryYellow,
                      child: Text(item.$1[0]),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              size: 16,
                              color: index < item.$2 ? AppColors.primaryYellow : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item.$3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentsTab extends StatelessWidget {
  const _StudentsTab();

  @override
  Widget build(BuildContext context) {
    final students = [
      ('Nguyễn Văn A', '2025-01-15', 85),
      ('Trần Thị B', '2025-01-14', 92),
      ('Lê Minh C', '2025-01-13', 78),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm học viên...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...students.map(
          (student) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryYellow,
                  child: Text(student.$1[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.$1,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tham gia: ${student.$2}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${student.$3}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: student.$3 / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

