import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rankingEntries = [
      _RankingEntry(
        position: 1,
        name: 'Thành Tô',
        points: 2320,
        days: 10,
        isCurrentUser: false,
      ),
      _RankingEntry(
        position: 2,
        name: 'Linh Kế',
        points: 2100,
        days: 8,
        isCurrentUser: false,
      ),
      _RankingEntry(
        position: 3,
        name: 'Trang Tô C',
        points: 2000,
        days: 7,
        isCurrentUser: false,
      ),
      _RankingEntry(
        position: 4,
        name: 'Minh Nguyễn',
        points: 1950,
        days: 9,
        isCurrentUser: false,
      ),
      _RankingEntry(
        position: 5,
        name: 'Livia Vaccaro',
        points: 1800,
        days: 6,
        isCurrentUser: true,
      ),
      _RankingEntry(
        position: 6,
        name: 'Hoa Lê',
        points: 1750,
        days: 8,
        isCurrentUser: false,
      ),
      _RankingEntry(
        position: 7,
        name: 'Anh Đỗ',
        points: 1700,
        days: 5,
        isCurrentUser: false,
      ),
      _RankingEntry(
        position: 8,
        name: 'Bình Trần',
        points: 1650,
        days: 7,
        isCurrentUser: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
        ),
        title: const Text(
          'Bảng xếp hạng',
          style: TextStyle(
            color: AppColors.primaryBlack,
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
            // Top 3 Podium - Duolingo style
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd place
                if (rankingEntries.length >= 2)
                  Column(
                    children: [
                      Container(
                        width: 70,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlack.withOpacity(0.7),
                              AppColors.primaryBlack.withOpacity(0.5),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryBlack,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryWhite,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryBlack,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '2',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Icon(
                              Icons.emoji_events,
                              color: AppColors.primaryWhite,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 70,
                        child: Text(
                          rankingEntries[1].name,
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
                        '${rankingEntries[1].points}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryBlack.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                // 1st place
                Column(
                  children: [
                    Container(
                      width: 90,
                      height: 130,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryYellow,
                            AppColors.primaryYellow.withOpacity(0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryBlack,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryYellow.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryWhite,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryBlack,
                                width: 3,
                              ),
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.emoji_events,
                            color: AppColors.primaryBlack,
                            size: 36,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 90,
                      child: Text(
                        rankingEntries[0].name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rankingEntries[0].points}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // 3rd place
                if (rankingEntries.length >= 3)
                  Column(
                    children: [
                      Container(
                        width: 70,
                        height: 85,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlack.withOpacity(0.6),
                              AppColors.primaryBlack.withOpacity(0.4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryBlack,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryWhite,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryBlack,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '3',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Icon(
                              Icons.emoji_events,
                              color: AppColors.primaryWhite,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 70,
                        child: Text(
                          rankingEntries[2].name,
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
                        '${rankingEntries[2].points}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryBlack.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 32),
            // Full ranking list - Duolingo style
            Container(
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
                children: rankingEntries
                    .map(
                      (entry) => Container(
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
                            // Position
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
                            // Avatar
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
                                        entry.name.isNotEmpty
                                            ? entry.name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: AppColors.primaryBlack,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name and stats
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: entry.isCurrentUser
                                                ? AppColors.primaryBlack
                                                : AppColors.primaryBlack,
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
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingEntry {
  final int position;
  final String name;
  final int points;
  final int days;
  final bool isCurrentUser;

  const _RankingEntry({
    required this.position,
    required this.name,
    required this.points,
    required this.days,
    this.isCurrentUser = false,
  });
}
