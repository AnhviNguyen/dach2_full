import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/payment_screen.dart';
import 'package:koreanhwa_flutter/features/course_classroom_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseTitle;
  final String instructorName;
  final double price;
  final double originalPrice;
  final int discount;
  final double rating;
  final int reviewCount;
  final int lessonCount;
  final int studentCount;
  final int daysAccess;

  const CourseDetailScreen({
    super.key,
    this.courseTitle = 'COMBO Khóa Luyện Thi TOPIK II + IBT MockTest',
    this.instructorName = 'Ninh Thị Thủy',
    this.price = 1430000,
    this.originalPrice = 1881579,
    this.discount = 24,
    this.rating = 5.0,
    this.reviewCount = 2,
    this.lessonCount = 45,
    this.studentCount = 3963,
    this.daysAccess = 90,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  bool _isRegistered = false;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _startPaymentFlow() async {
    if (_isProcessingPayment) return;
    setState(() {
      _isProcessingPayment = true;
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          courseTitle: widget.courseTitle,
          amount: widget.price,
          onPaymentResult: (success) {
            if (success && mounted) {
              setState(() {
                _isRegistered = true;
              });
            }
          },
        ),
      ),
    );
    if (mounted) {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            _buildCourseHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildIntroductionTab(),
                  _buildContentTab(),
                  _buildInstructorTab(),
                  _buildGiftsTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : AppColors.primaryBlack,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryBlack),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book, color: AppColors.primaryBlack, size: 24),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: AppColors.primaryBlack, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryWhite,
                height: 1.3,
              ),
              children: [
                const TextSpan(text: 'COMBO '),
                TextSpan(
                  text: 'Khóa Luyện Thi TOPIK II',
                  style: TextStyle(color: AppColors.primaryYellow),
                ),
                const TextSpan(text: ' + IBT MockTest'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _tabController.animateTo(2); // Navigate to Instructor tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlack,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Giảng viên: ${widget.instructorName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryYellow,
        indicatorWeight: 3,
        labelColor: AppColors.primaryYellow,
        unselectedLabelColor: AppColors.primaryBlack.withOpacity(0.6),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(icon: Icon(Icons.description, size: 20), text: 'Giới thiệu'),
          Tab(icon: Icon(Icons.folder, size: 20), text: 'Nội dung'),
          Tab(icon: Icon(Icons.person, size: 20), text: 'Giảng viên'),
          Tab(icon: Icon(Icons.card_giftcard, size: 20), text: 'Quà tặng'),
          Tab(icon: Icon(Icons.star, size: 20), text: 'Đánh giá'),
        ],
      ),
    );
  }

  Widget _buildIntroductionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseInfoCard(),
          const SizedBox(height: 24),
          _buildPricingSection(),
          const SizedBox(height: 24),
          _buildDiscountTimer(),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    final lessons = [
      _LessonItem(
        title: 'Giới thiệu khóa học',
        duration: '00:02:26',
        isLocked: false,
        isCompleted: true,
      ),
      _LessonItem(
        title: '[Bài 1 - Phần đọc] Chọn ngữ pháp đúng điền vào ô trống [1-2]',
        duration: '00:18:04',
        isLocked: false,
        isCompleted: true,
      ),
      _LessonItem(
        title: '[Bài 2 - Phần đọc] Chọn ngữ pháp có nghĩa tương tự [3-4]',
        duration: '00:15:18',
        isLocked: false,
        isCompleted: true,
      ),
      _LessonItem(
        title: '[Bài 3 - Phần đọc] Hiểu nội dung đoạn văn ngắn [5-8]',
        duration: '00:22:48',
        isLocked: true,
        isCompleted: false,
      ),
      _LessonItem(
        title: '[Bài 4 - Phần đọc] Đọc hiểu đoạn văn dài [9-12]',
        duration: '00:28:30',
        isLocked: true,
        isCompleted: false,
      ),
      _LessonItem(
        title: '[Bài 5 - Phần nghe] Nghe hiểu nội dung cơ bản [13-16]',
        duration: '00:25:15',
        isLocked: true,
        isCompleted: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryBlack.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                lesson.isLocked ? Icons.lock : Icons.play_circle_filled,
                color: lesson.isLocked
                    ? AppColors.grayLight
                    : AppColors.primaryYellow,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: lesson.isLocked
                            ? AppColors.primaryBlack.withOpacity(0.5)
                            : AppColors.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.primaryBlack.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lesson.duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlack.withOpacity(0.6),
                    ),
                  ),
                  if (!lesson.isLocked && lesson.isCompleted) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryYellow.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primaryYellow,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.instructorName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Giảng viên Tiếng Hàn',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryBlack.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInstructorStat('Khóa học', '${widget.lessonCount}'),
                    _buildInstructorStat('Học viên', '${widget.studentCount}'),
                    _buildInstructorStat('Đánh giá', '${widget.rating}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giới thiệu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Giảng viên với nhiều năm kinh nghiệm trong việc giảng dạy tiếng Hàn. Chuyên về luyện thi TOPIK và các chứng chỉ quốc tế khác.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryBlack.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primaryBlack.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildGiftsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow,
                  AppColors.primaryYellow.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 60,
                  color: AppColors.primaryBlack,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quà tặng đặc biệt',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Khi đăng ký khóa học này, bạn sẽ nhận được:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryBlack.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildGiftItem('Tài liệu PDF', Icons.picture_as_pdf),
          _buildGiftItem('Video bài giảng', Icons.video_library),
          _buildGiftItem('Bài tập thực hành', Icons.assignment),
          _buildGiftItem('Hỗ trợ 1-1', Icons.support_agent),
        ],
      ),
    );
  }

  Widget _buildGiftItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryYellow.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlack, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final reviews = [
      _ReviewItem(
        userName: 'Nguyễn Văn A',
        rating: 5,
        comment: 'Khóa học rất hay, giảng viên nhiệt tình và dễ hiểu!',
        date: '2 ngày trước',
      ),
      _ReviewItem(
        userName: 'Trần Thị B',
        rating: 5,
        comment: 'Nội dung phong phú, bài tập thực hành rất hữu ích.',
        date: '5 ngày trước',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.primaryYellow, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.rating}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    Text(
                      '${widget.reviewCount} đánh giá',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlack.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...reviews.map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(_ReviewItem review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryYellow,
                radius: 20,
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 16,
                          color: index < review.rating
                              ? AppColors.primaryYellow
                              : AppColors.grayLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                review.date,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryBlack.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryBlack.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '[-${widget.discount}%]',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.courseTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => const Icon(
                  Icons.star,
                  color: AppColors.primaryYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.rating}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.reviewCount} đánh giá',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryBlack.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, widget.instructorName),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.menu_book, '${widget.lessonCount} Bài giảng'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, '${widget.daysAccess} ngày'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.people, '${widget.studentCount} học viên đã đăng ký'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlack.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primaryBlack.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    final formattedPrice = _formatPrice(widget.price);
    final formattedOriginalPrice = _formatPrice(widget.originalPrice);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$formattedPrice đ',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$formattedOriginalPrice đ',
                style: TextStyle(
                  fontSize: 18,
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.primaryBlack.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '-${widget.discount}%',
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountTimer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Thời gian ưu đãi còn lại',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimerBox('2', 'Ngày'),
              _buildTimerBox('23', 'giờ'),
              _buildTimerBox('59', 'phút'),
              _buildTimerBox('04', 'giây'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRegistered
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseClassroomScreen(courseTitle: widget.courseTitle),
                        ),
                      );
                    }
                  : (_isProcessingPayment ? null : _startPaymentFlow),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isRegistered
                  ? const Column(
                      children: [
                        Text(
                          'KHÓA HỌC ĐĂNG KÝ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '(Đi Đến Phòng Học)',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _isProcessingPayment ? 'Đang xử lý...' : 'ĐĂNG KÝ KHÓA HỌC',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: AppColors.primaryBlack,
              ),
              label: const Text(
                'LƯU KHÓA HỌC',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryBlack,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(color: AppColors.primaryBlack, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _LessonItem {
  final String title;
  final String duration;
  final bool isLocked;
  final bool isCompleted;

  _LessonItem({
    required this.title,
    required this.duration,
    required this.isLocked,
    required this.isCompleted,
  });
}

class _ReviewItem {
  final String userName;
  final int rating;
  final String comment;
  final String date;

  _ReviewItem({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

