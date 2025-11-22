import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/shared/widgets/main_bottom_nav.dart';
import 'package:koreanhwa_flutter/features/course_detail_screen.dart';
import 'package:koreanhwa_flutter/features/course_list_screen.dart';
import 'package:koreanhwa_flutter/features/achievements_screen.dart';
import 'package:koreanhwa_flutter/features/ranking_screen.dart';
import 'package:koreanhwa_flutter/features/textbook_screen.dart';
import 'package:koreanhwa_flutter/features/topik/topik_library_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showNavigationMenu = false;
  MainNavItem _currentNavItem = MainNavItem.home;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Định nghĩa màu sắc
  static const Color colorPurple = Color(0xFF8B5CF6);
  static const Color colorBlue = Color(0xFF3B82F6);
  static const Color colorPink = Color(0xFFEC4899);
  static const Color colorOrange = Color(0xFFF97316);
  static const Color colorGreen = Color(0xFF10B981);
  static const Color colorRed = Color(0xFFEF4444);
  static const Color colorCyan = Color(0xFF06B6D4);
  static const Color colorIndigo = Color(0xFF6366F1);

  final List<_MenuItem> _menuItems = const [
    _MenuItem(icon: Icons.article_outlined, label: 'Blog', color: colorPurple),
    _MenuItem(icon: Icons.emoji_events_outlined, label: 'Cuộc thi', color: colorOrange),
    _MenuItem(icon: Icons.quiz_outlined, label: 'Luyện thi topik', color: colorBlue),
    _MenuItem(icon: Icons.book_outlined, label: 'Từ vựng của tôi', color: colorGreen),
    _MenuItem(icon: Icons.menu_book_outlined, label: 'Giáo trình', color: colorPink),
    _MenuItem(icon: Icons.school_outlined, label: 'Khóa học', color: colorCyan),
    _MenuItem(icon: Icons.map_outlined, label: 'Roadmap', color: colorIndigo),
    _MenuItem(icon: Icons.assignment_outlined, label: 'Nhiệm vụ', color: AppColors.primaryYellow),
    _MenuItem(icon: Icons.mic_outlined, label: 'Luyện nói', color: colorRed),
    _MenuItem(icon: Icons.folder_outlined, label: 'Tài liệu', color: colorPurple),
    _MenuItem(icon: Icons.settings_outlined, label: 'Cài đặt', color: AppColors.primaryBlack),
  ];

  final List<_TaskItem> _dailyTasks = const [
    _TaskItem(
      title: 'Học từ vựng',
      icon: Icons.book_outlined,
      color: Color(0xFFFFFBEB),
      progressColor: AppColors.primaryYellow,
      progressPercent: 0.7,
    ),
    _TaskItem(
      title: 'Học ngữ pháp',
      icon: Icons.translate,
      color: Color(0xFFF5F5F5),
      progressColor: AppColors.primaryBlack,
      progressPercent: 0.52,
    ),
    _TaskItem(
      title: 'Luyện đề',
      icon: Icons.menu_book_outlined,
      color: Color(0xFFFFFBEB),
      progressColor: colorOrange,
      progressPercent: 0.87,
    ),
  ];

  final List<_LessonCardData> _lessonCards = const [
    _LessonCardData(
      title: 'Tiếng Hàn Sơ cấp 1',
      date: '12/11/2025',
      tag: 'MAR 05',
      accentColor: AppColors.primaryYellow,
      backgroundColor: Color(0xFFFFFBEB),
    ),
    _LessonCardData(
      title: 'Tiếng Hàn sơ cấp 2',
      date: '13/11/2025',
      tag: 'MAR 05',
      accentColor: colorOrange,
      backgroundColor: Color(0xFFFFEDD5),
    ),
    _LessonCardData(
      title: 'Tiếng Hàn trung cấp 1',
      date: '14/11/2025',
      tag: 'MAR 05',
      accentColor: AppColors.primaryBlack,
      backgroundColor: Color(0xFFF5F5F5),
    ),
  ];

  final List<_CourseCardData> _courseCards = const [
    _CourseCardData(
      title: 'Khóa học giao tiếp cơ bản',
      progress: 0.65,
      lessons: 24,
      completed: 16,
      accentColor: AppColors.primaryYellow,
    ),
    _CourseCardData(
      title: 'Khóa học luyện thi TOPIK I',
      progress: 0.40,
      lessons: 30,
      completed: 12,
      accentColor: colorOrange,
    ),
    _CourseCardData(
      title: 'Khóa học từ vựng nâng cao',
      progress: 0.80,
      lessons: 20,
      completed: 16,
      accentColor: colorPurple,
    ),
  ];

  final List<_StatChipData> _statChips = const [
    _StatChipData(
      title: 'Cấp độ hiện tại',
      value: 'Trung cấp',
      color: AppColors.primaryYellow,
      icon: Icons.school,
    ),
    _StatChipData(
      title: 'Tiến độ học',
      value: '30%',
      color: colorOrange,
      icon: Icons.trending_up,
    ),
    _StatChipData(
      title: 'Streak học tập',
      value: '12 ngày',
      color: AppColors.primaryBlack,
      icon: Icons.local_fire_department,
    ),
  ];

  final List<_RecentAchievement> _recentAchievements = const [
    _RecentAchievement(
      iconLabel: '🎯',
      title: 'Hoàn thành Bài học',
      subtitle: 'Bài 1: Giới thiệu bản thân',
      count: 2,
      color: AppColors.primaryYellow,
    ),
    _RecentAchievement(
      iconLabel: '🔥',
      title: 'Streak 10 ngày',
      subtitle: 'Học liên tục 10 ngày',
      count: 1,
      color: colorOrange,
    ),
    _RecentAchievement(
      iconLabel: '📚',
      title: 'Tích lũy 1000 từ vựng',
      subtitle: 'Học từ vựng mỗi ngày',
      count: 2,
      color: colorGreen,
    ),
  ];

  final List<_RankingEntry> _rankingEntries = const [
    _RankingEntry(
      position: 1,
      name: 'Thành Tô',
      points: 2320,
      days: 10,
      color: AppColors.primaryYellow,
    ),
    _RankingEntry(
      position: 2,
      name: 'Linh Kế',
      points: 2100,
      days: 8,
      color: Color(0xFFE5E7EB),
    ),
    _RankingEntry(
      position: 3,
      name: 'Trang Tô C',
      points: 2000,
      days: 7,
      color: Color(0xFFFFEDD5),
    ),
  ];

  final List<_SkillProgress> _skills = const [
    _SkillProgress(label: 'Nghe', percent: 0.75, color: AppColors.primaryYellow),
    _SkillProgress(label: 'Nói', percent: 0.6, color: colorOrange),
    _SkillProgress(label: 'Đọc', percent: 0.85, color: colorGreen),
    _SkillProgress(label: 'Viết', percent: 0.45, color: colorPurple),
  ];

  // Trạng thái học trong tuần (true = đã học, false = chưa học)
  final List<_DayTab> _weekDays = [
    _DayTab('T2', true, AppColors.primaryYellow),
    _DayTab('T3', true, AppColors.primaryYellow),
    _DayTab('T4', false, AppColors.primaryBlack),
    _DayTab('T5', false, AppColors.primaryBlack),
    _DayTab('T6', false, AppColors.primaryBlack),
    _DayTab('T7', false, AppColors.primaryBlack),
    _DayTab('CN', false, AppColors.primaryBlack),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodayMissionCard(),
                    const SizedBox(height: 24),
                    _buildQuickAccessGrid(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Nhiệm vụ hôm nay', Icons.task_alt),
                        TextButton(
                          onPressed: () => _showAllTasksBottomSheet(context),
                          child: const Text(
                            'Xem tất cả',
                            style: TextStyle(
                              color: AppColors.primaryYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._dailyTasks.map((task) => _DailyTaskTile(task: task)),
                    const SizedBox(height: 24),
                    _buildStatChips(),
                    const SizedBox(height: 24),
                    _buildStreakSection(),
                    const SizedBox(height: 24),
                    _buildScheduleTabs(),
                    const SizedBox(height: 24),
                    _buildLessonSection(
                      title: 'Bài đang học',
                      icon: Icons.play_circle_outline,
                      actionLabel: 'Xem thêm',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CourseListScreen(title: 'Bài đang học'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildCourseSection(
                      title: 'Khóa học đang học',
                      icon: Icons.school_outlined,
                      actionLabel: 'Xem thêm',
                      onTap: () {
                        context.push('/lessons');
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildAchievementSection(),
                    const SizedBox(height: 24),
                    _buildRankingSection(),
                    const SizedBox(height: 24),
                    _buildSkillProgressSection(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: MainBottomNavBar(
        current: _currentNavItem,
        onChanged: (item) {
          setState(() {
            _currentNavItem = item;
          });
          switch (item) {
            case MainNavItem.home:
              if (context.canPop()) {
                context.go('/home');
              }
              break;
            case MainNavItem.curriculum:
              context.push('/textbook');
              break;
            case MainNavItem.lessons:
              context.push('/lessons');
              break;
            case MainNavItem.vocabulary:
              context.push('/my-vocabulary');
              break;
            case MainNavItem.settings:
              context.push('/settings');
              break;
          }
        },
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: const Icon(Icons.menu_rounded, color: AppColors.primaryBlack),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryYellow, width: 3),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(3),
            child: const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('lib/utils/images/image.png'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Xin chào,',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Livia Vaccaro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_none_outlined, color: AppColors.primaryBlack),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: colorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: AppColors.primaryWhite,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.primaryYellow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('lib/utils/images/image.png'),
                          backgroundColor: AppColors.primaryWhite,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Livia Vaccaro',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Học viên Trung cấp',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDrawerStat('12', 'Streak', Icons.local_fire_department),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDrawerStat('30%', 'Tiến độ', Icons.trending_up),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDrawerStat('5', 'Khóa học', Icons.school),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.color.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: item.color.withOpacity(0.5),
                        size: 24,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _handleMenuNavigation(item.label);
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.primaryBlack.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    size: 20,
                    color: colorRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlack, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final quickAccess = [
      _QuickAccessItem('Blog', Icons.article, colorPurple, () => context.push('/blog')),
      _QuickAccessItem('Cuộc thi', Icons.emoji_events, colorOrange, () => context.push('/competition')),
      _QuickAccessItem('TOPIK', Icons.quiz, colorBlue, () => context.push('/topik-library')),
      _QuickAccessItem('Từ vựng', Icons.book, colorGreen, () => context.push('/my-vocabulary')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Truy cập nhanh', Icons.dashboard),
        const SizedBox(height: 12),
        Row(
          children: quickAccess.map((item) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item.icon, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTodayMissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryYellow.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🎯 Nhiệm vụ hôm nay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bạn gần hoàn thành nhiệm vụ rồi!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text(
                    'Xem tasks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: AppColors.primaryWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlack.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              height: 90,
              width: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 90,
                    width: 90,
                    child: CircularProgressIndicator(
                      value: 0.85,
                      strokeWidth: 8,
                      backgroundColor: AppColors.primaryBlack.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlack),
                    ),
                  ),
                  const Text(
                    '85%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryBlack),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChips() {
    return Row(
      children: _statChips.map((chip) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: chip.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: chip.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(chip.icon, color: chip.color, size: 24),
                const SizedBox(height: 8),
                Text(
                  chip.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: chip.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  chip.title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStreakSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Streak học tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StreakStat(title: 'Ngày học', value: '12', color: colorOrange, icon: Icons.check_circle),
              _StreakStat(title: 'Ngày nghỉ', value: '25', color: colorPink, icon: Icons.event_busy),
              _StreakStat(title: 'Chưa học', value: '89', color: colorPurple, icon: Icons.pending),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colorOrange.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colorOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Lịch học trong tuần', Icons.calendar_today),
        const SizedBox(height: 12),

        // Tăng chiều cao để tránh overflow
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _weekDays.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final day = _weekDays[index];

              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: day.isStudied
                        ? AppColors.primaryYellow
                        : AppColors.primaryWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: day.isStudied
                          ? AppColors.primaryYellow
                          : AppColors.primaryBlack.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.label,
                        style: const TextStyle(
                          color: AppColors.primaryBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Icon hoặc vòng tròn rỗng
                      day.isStudied
                          ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlack,
                        size: 20,
                      )
                          : Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlack.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLessonSection({
    required String title,
    required IconData icon,
    required String actionLabel,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(title, icon),
            TextButton.icon(
              onPressed: onTap ?? () {},
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                actionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _lessonCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final card = _lessonCards[index];
              return Container(
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primaryWhite,
                  boxShadow: [
                    BoxShadow(
                      color: card.accentColor.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top image/icon section
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: card.backgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: card.accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  card.tag,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Icon(
                                Icons.menu_book,
                                size: 50,
                                color: card.accentColor.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom info + button (không dùng Expanded)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // quan trọng
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: card.accentColor),
                              const SizedBox(width: 4),
                              Text(
                                card.date,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primaryBlack.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12), // cách nút với content
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailScreen(
                                      courseTitle: card.title,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: card.accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Vào học',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSection({
    required String title,
    required IconData icon,
    required String actionLabel,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Header ----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(title, icon),
            TextButton.icon(
              onPressed: onTap ?? () {},
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                actionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryYellow,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ---- Course List ----
        SizedBox(
          height: 230, // ⭐ Quan trọng: NGĂN Overflow
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _courseCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final course = _courseCards[index];

              return Container(
                width: 280,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: course.accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: course.accentColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Title & Icon ----
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: course.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.school,
                            color: course.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            course.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ---- Lessons & progress % ----
                    Row(
                      children: [
                        Icon(
                          Icons.playlist_play,
                          size: 16,
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.completed}/${course.lessons} bài học',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryBlack.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(course.progress * 100).round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: course.accentColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ---- Progress bar ----
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: course.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: course.progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: course.accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---- Button ----
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailScreen(
                                courseTitle: course.title,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: course.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Tiếp tục học',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }



  Widget _buildAchievementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Thành tích gần đây', Icons.emoji_events),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AchievementsScreen(),
                  ),
                );
              },
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: AppColors.primaryYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: _recentAchievements.map((achievement) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: achievement.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: achievement.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: achievement.color,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        achievement.iconLabel,
                        style: const TextStyle(
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryBlack.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: achievement.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${achievement.count}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRankingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Bảng xếp hạng', Icons.leaderboard),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RankingScreen(),
                  ),
                );
              },
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: colorOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _rankingEntries.map((entry) {
                  return Column(
                    children: [
                      Container(
                        width: 75,
                        height: 95,
                        decoration: BoxDecoration(
                          color: entry.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '#${entry.position}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: entry.position == 1 ? AppColors.primaryBlack : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.emoji_events,
                              color: entry.position == 1 ? AppColors.primaryBlack : Colors.black87,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${entry.points} điểm',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tiến độ kỹ năng', Icons.trending_up),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _skills.map((skill) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: skill.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getSkillIcon(skill.label),
                            size: 20,
                            color: skill.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            skill.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          '${(skill.percent * 100).round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: skill.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: skill.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: skill.percent,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: skill.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getSkillIcon(String label) {
    switch (label) {
      case 'Nghe':
        return Icons.hearing;
      case 'Nói':
        return Icons.record_voice_over;
      case 'Đọc':
        return Icons.menu_book;
      case 'Viết':
        return Icons.edit;
      default:
        return Icons.school;
    }
  }

  void _handleMenuNavigation(String label) {
    switch (label) {
      case 'Blog':
        context.push('/blog');
        break;
      case 'Cuộc thi':
        context.push('/competition');
        break;
      case 'Luyện thi topik':
        context.push('/topik-library');
        break;
      case 'Từ vựng của tôi':
        context.push('/my-vocabulary');
        break;
      case 'Giáo trình':
        context.push('/textbook');
        break;
      case 'Khóa học':
        context.push('/lessons');
        break;
      case 'Roadmap':
        context.push('/roadmap');
        break;
      case 'Tài liệu':
        context.push('/material');
        break;
      case 'Cài đặt':
        context.push('/settings');
        break;
      case 'Luyện nói':
        context.push('/speak-practice');
        break;
    }
  }

  void _showAllTasksBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.task_alt, size: 20, color: AppColors.primaryBlack),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Nhiệm vụ hôm nay',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: AppColors.primaryBlack),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        ..._dailyTasks.map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DailyTaskTile(task: task),
                        )),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryBlack,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// Data Models
class _TaskItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color progressColor;
  final double progressPercent;

  const _TaskItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.progressColor,
    required this.progressPercent,
  });
}

class _DailyTaskTile extends StatelessWidget {
  final _TaskItem task;

  const _DailyTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.progressColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: task.progressColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: task.progressColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.progressColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(task.icon, color: task.progressColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: task.progressColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: task.progressPercent,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: task.progressColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(task.progressPercent * 100).round()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: task.progressColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChipData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatChipData({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class _LessonCardData {
  final String title;
  final String date;
  final String tag;
  final Color accentColor;
  final Color backgroundColor;

  const _LessonCardData({
    required this.title,
    required this.date,
    required this.tag,
    required this.accentColor,
    required this.backgroundColor,
  });
}

class _CourseCardData {
  final String title;
  final double progress;
  final int lessons;
  final int completed;
  final Color accentColor;

  const _CourseCardData({
    required this.title,
    required this.progress,
    required this.lessons,
    required this.completed,
    required this.accentColor,
  });
}

class _StreakStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StreakStat({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecentAchievement {
  final String iconLabel;
  final String title;
  final String subtitle;
  final int count;
  final Color color;

  const _RecentAchievement({
    required this.iconLabel,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.color,
  });
}

class _RankingEntry {
  final int position;
  final String name;
  final int points;
  final int days;
  final Color color;

  const _RankingEntry({
    required this.position,
    required this.name,
    required this.points,
    required this.days,
    required this.color,
  });
}

class _SkillProgress {
  final String label;
  final double percent;
  final Color color;

  const _SkillProgress({
    required this.label,
    required this.percent,
    required this.color,
  });
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _QuickAccessItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickAccessItem(this.label, this.icon, this.color, this.onTap);
}

class _DayTab {
  final String label;
  final bool isStudied;
  final Color color;

  _DayTab(this.label, this.isStudied, this.color);
}