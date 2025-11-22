import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/courses/presentation/screen/course_detail_screen.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/shared/widgets/main_bottom_nav.dart';
import 'package:koreanhwa_flutter/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:koreanhwa_flutter/features/ranking/presentation/screens/ranking_screen.dart';
import 'package:koreanhwa_flutter/features/home/data/home_mock_data.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/today_mission_card.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/quick_access_grid.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/daily_task_tile.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/stat_chips.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/streak_section.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/schedule_tabs.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showNavigationMenu = false;
  MainNavItem _currentNavItem = MainNavItem.home;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                    const TodayMissionCard(),
                    const SizedBox(height: 24),
                    const QuickAccessGrid(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionHeader(title: 'Nhiệm vụ hôm nay', icon: Icons.task_alt),
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
                    ...HomeMockData.dailyTasks.map((task) => DailyTaskTile(task: task)),
                    const SizedBox(height: 24),
                    StatChips(statChips: HomeMockData.statChips),
                    const SizedBox(height: 24),
                    const StreakSection(),
                    const SizedBox(height: 24),
                    ScheduleTabs(weekDays: HomeMockData.weekDays),
                    const SizedBox(height: 24),
                    _buildLessonSection(
                      title: 'Giáo trình đang học',
                      icon: Icons.play_circle_outline,
                      actionLabel: 'Xem thêm',
                      onTap: () {
                        context.push('/textbook');
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
    const colorRed = Color(0xFFEF4444);
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
    const colorRed = Color(0xFFEF4444);
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
                itemCount: HomeMockData.menuItems.length,
                itemBuilder: (context, index) {
                  final item = HomeMockData.menuItems[index];
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
            SectionHeader(title: title, icon: icon),
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
            itemCount: HomeMockData.lessonCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final card = HomeMockData.lessonCards[index];
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/textbook');
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionHeader(title: title, icon: icon),
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
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: HomeMockData.courseCards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final course = HomeMockData.courseCards[index];
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
            const SectionHeader(title: 'Thành tích gần đây', icon: Icons.emoji_events),
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
          children: HomeMockData.recentAchievements.map((achievement) {
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
            const SectionHeader(title: 'Bảng xếp hạng', icon: Icons.leaderboard),
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
                  color: Color(0xFFF97316),
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
                children: HomeMockData.rankingEntries.map((entry) {
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
        const SectionHeader(title: 'Tiến độ kỹ năng', icon: Icons.trending_up),
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
            children: HomeMockData.skills.map((skill) {
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
                        ...HomeMockData.dailyTasks.map((task) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DailyTaskTile(task: task),
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

