import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/ranking/data/models/ranking_entry.dart';
import 'package:koreanhwa_flutter/features/ranking/data/services/ranking_api_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<RankingEntry> rankingEntries = [];
  bool isLoading = true;
  final RankingApiService _apiService = RankingApiService();

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    try {
      final entries = await _apiService.getAllRankings();
      setState(() {
        rankingEntries = entries;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
          ),
          title: Text(
            'Bảng xếp hạng',
            style: TextStyle(
              color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
        ),
        title: Text(
          'Bảng xếp hạng',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.leaderboard,
                      size: 40,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top học viên',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${rankingEntries.length} học viên trong bảng xếp hạng',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryBlack.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildTop3Podium(rankingEntries),
            const SizedBox(height: 32),
            _buildRankingList(rankingEntries),
          ],
        ),
      ),
    );
  }

  Widget _buildTop3Podium(List<RankingEntry> entries) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (entries.length >= 2) _buildPodiumItem(entries[1], 2, 100),
        _buildPodiumItem(entries[0], 1, 130),
        if (entries.length >= 3) _buildPodiumItem(entries[2], 3, 85),
      ],
    );
  }

  Widget _buildPodiumItem(RankingEntry entry, int position, double height) {
    final isFirst = position == 1;
    return Column(
      children: [
        Container(
          width: isFirst ? 90 : 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isFirst
                  ? [
                      AppColors.primaryYellow,
                      AppColors.primaryYellow.withOpacity(0.9),
                    ]
                  : [
                      AppColors.primaryBlack.withOpacity(0.7),
                      AppColors.primaryBlack.withOpacity(0.5),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(isFirst ? 20 : 16),
            border: Border.all(
              color: AppColors.primaryBlack,
              width: isFirst ? 3 : 2,
            ),
            boxShadow: isFirst
                ? [
                    BoxShadow(
                      color: AppColors.primaryYellow.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isFirst ? 8 : 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBlack,
                    width: isFirst ? 3 : 2,
                  ),
                ),
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontSize: isFirst ? 28 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.emoji_events,
                color: isFirst ? AppColors.primaryBlack : AppColors.primaryWhite,
                size: isFirst ? 36 : 24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: isFirst ? 90 : 70,
          child: Text(
            entry.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${entry.points}',
          style: TextStyle(
            fontSize: isFirst ? 12 : 11,
            color: isFirst ? AppColors.primaryBlack : AppColors.primaryBlack.withOpacity(0.7),
            fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingList(List<RankingEntry> entries) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: entry.isCurrentUser
                  ? AppColors.primaryYellow.withOpacity(0.2)
                  : AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: entry.isCurrentUser
                    ? AppColors.primaryYellow
                    : AppColors.primaryBlack.withOpacity(0.1),
                width: entry.isCurrentUser ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '#${entry.position}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: entry.position <= 3
                          ? AppColors.primaryYellow
                          : AppColors.primaryBlack.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: entry.position <= 3
                        ? AppColors.primaryYellow
                        : AppColors.primaryBlack.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBlack,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: entry.position <= 3
                        ? Icon(
                            Icons.emoji_events,
                            color: AppColors.primaryBlack,
                            size: 24,
                          )
                        : Text(
                            entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: AppColors.primaryBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ),
                          if (entry.isCurrentUser)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryBlack,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Bạn',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.primaryYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.points} XP',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBlack.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: AppColors.primaryYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.days} ngày',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBlack.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

