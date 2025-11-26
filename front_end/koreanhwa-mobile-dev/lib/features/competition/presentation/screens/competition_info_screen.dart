import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition.dart';
import 'package:koreanhwa_flutter/features/competition/data/services/competition_api_service.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_join_screen.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';

class CompetitionInfoScreen extends ConsumerStatefulWidget {
  final int? competitionId;
  final Competition? competition;

  const CompetitionInfoScreen({super.key, this.competitionId, this.competition});

  @override
  ConsumerState<CompetitionInfoScreen> createState() => _CompetitionInfoScreenState();
}

class _CompetitionInfoScreenState extends ConsumerState<CompetitionInfoScreen> {
  String _activeTab = 'overview';
  final CompetitionApiService _apiService = CompetitionApiService();
  Competition? _competition;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      _competition = widget.competition;
      _isLoading = false;
    } else if (widget.competitionId != null) {
      _loadCompetition();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadCompetition() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = ref.read(authProvider).user?.id;
      final competition = await _apiService.getCompetitionById(widget.competitionId!, currentUserId: userId);
      setState(() {
        _competition = competition;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryWhite,
        appBar: AppBar(
          backgroundColor: AppColors.primaryWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Đang tải...',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final competition = _competition;
    if (competition == null || _errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.primaryWhite,
        appBar: AppBar(
          backgroundColor: AppColors.primaryWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Lỗi',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage ?? 'Cuộc thi không tồn tại',
                style: const TextStyle(color: AppColors.primaryBlack),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.competitionId != null ? _loadCompetition : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.primaryBlack,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => context.pop(),
        ),
        title: Text(
          competition.title,
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primaryBlack),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow,
                  AppColors.primaryYellow.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.emoji_events,
                    size: 100,
                    color: AppColors.primaryBlack.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlack,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          competition.category,
                          style: const TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        competition.description,
                        style: const TextStyle(
                          color: AppColors.primaryBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          Container(
            color: AppColors.primaryWhite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('overview', 'Tổng quan', Icons.info),
                  _buildTab('leaderboard', 'Bảng xếp hạng', Icons.emoji_events),
                  _buildTab('contests', 'Cuộc thi', Icons.quiz),
                  _buildTab('schedule', 'Lịch trình', Icons.calendar_today),
                  _buildTab('achievements', 'Thành tích', Icons.stars),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: _buildTabContent(competition),
          ),
        ],
      ),
      floatingActionButton: competition != null && competition.status == 'active'
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompetitionJoinScreen(
                      competition: competition,
                      competitionId: competition.id,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.primaryBlack,
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'Tham gia thi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildTab(String id, String label, IconData icon) {
    final isSelected = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryYellow : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primaryYellow : AppColors.grayLight,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBlack : AppColors.grayLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(Competition competition) {
    switch (_activeTab) {
      case 'overview':
        return _buildOverviewTab(competition);
      case 'leaderboard':
        return _buildLeaderboardTab(competition);
      case 'contests':
        return _buildContestsTab(competition);
      case 'schedule':
        return _buildScheduleTab(competition);
      case 'achievements':
        return _buildAchievementsTab(competition);
      default:
        return _buildOverviewTab(competition);
    }
  }

  Widget _buildOverviewTab(Competition competition) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(Icons.people, '${competition.participants}', 'Thí sinh', AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(Icons.quiz, '12', 'Cuộc thi', AppColors.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(Icons.emoji_events, '${(competition.totalPrize / 1000000).toStringAsFixed(0)}M', 'Giải thưởng', AppColors.primaryYellow),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.whiteGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Về cuộc thi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  competition.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryBlack,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin chi tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.access_time, 'Thời gian:', competition.timeLimit),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.attach_money, 'Phí tham gia:', competition.entryFee == 0 ? 'Miễn phí' : '${_formatNumber(competition.entryFee)}đ'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.calendar_today, 'Hạn chót:', _formatDate(competition.deadline)),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.category, 'Danh mục:', competition.category),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryYellow, AppColors.primaryYellow.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tham gia ngay!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bắt đầu thử thách với bài thi mới nhất.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: competition != null && competition.status == 'active'
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompetitionJoinScreen(
                                  competition: competition,
                                  competitionId: competition.id,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlack,
                            foregroundColor: AppColors.primaryWhite,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Tham gia thi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              competition?.status == 'upcoming'
                                  ? 'Cuộc thi chưa bắt đầu'
                                  : competition?.status == 'completed'
                                      ? 'Cuộc thi đã kết thúc'
                                      : 'Không thể tham gia',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
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
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grayLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryYellow, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grayLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab(Competition competition) {
    // TODO: Load leaderboard from API when endpoint is available
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bảng xếp hạng',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.emoji_events, size: 64, color: AppColors.grayLight),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có dữ liệu xếp hạng',
                    style: TextStyle(color: AppColors.grayLight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContestsTab(Competition competition) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Các cuộc thi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.quiz, size: 64, color: AppColors.grayLight),
                  const SizedBox(height: 16),
                  Text(
                    'Danh sách các cuộc thi sẽ được cập nhật sớm',
                    style: TextStyle(color: AppColors.grayLight),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(Competition competition) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch trình',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.whiteGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildScheduleItem('Đăng ký', competition.deadline.subtract(const Duration(days: 7)), true),
                const SizedBox(height: 16),
                _buildScheduleItem('Thi', competition.deadline, false),
                const SizedBox(height: 16),
                _buildScheduleItem('Công bố kết quả', competition.deadline.add(const Duration(days: 3)), false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String title, DateTime date, bool isActive) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryYellow : AppColors.grayLight,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isActive ? AppColors.primaryBlack : AppColors.grayLight,
                ),
              ),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grayLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab(Competition competition) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thành tích',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildAchievementCard('Hạng 1', Icons.emoji_events, AppColors.primaryYellow),
              _buildAchievementCard('Top 10', Icons.star, AppColors.warning),
              _buildAchievementCard('Hoàn thành', Icons.check_circle, AppColors.success),
              _buildAchievementCard('Tham gia', Icons.person, AppColors.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    final numberStr = number.toString();
    final reversed = numberStr.split('').reversed.join();
    final chunks = <String>[];
    for (int i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.substring(i, (i + 3 > reversed.length) ? reversed.length : i + 3));
    }
    return chunks.join('.').split('').reversed.join();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
