import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/achievements/data/models/achievement_item.dart';
import 'package:koreanhwa_flutter/features/achievements/data/services/achievement_api_service.dart';
import 'package:koreanhwa_flutter/features/achievements/presentation/widgets/achievement_card.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';


class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  final AchievementApiService _apiService = AchievementApiService();
  List<AchievementItem> _achievements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      setState(() {
        _error = 'User not authenticated';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final achievements = await _apiService.getUserAchievements(userId);
      setState(() {
        _achievements = achievements;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_isLoading) {
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
            'Thành tích',
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

    if (_error != null) {
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
            'Thành tích',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAchievements,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final completedCount = _achievements.where((a) => a.isCompleted).length;
    final totalProgress = _achievements.isEmpty
        ? 0.0
        : _achievements.fold<double>(0, (sum, a) => sum + a.progress) / _achievements.length;

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
          'Thành tích',
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
                  const Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: AppColors.primaryBlack,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng thành tích',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completedCount/${_achievements.length} thành tích đã đạt được',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryBlack.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: totalProgress,
                            minHeight: 8,
                            backgroundColor: AppColors.primaryBlack.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlack),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: List.generate(
                    _achievements.length,
                    (index) {
                      final achievement = _achievements[index];
                      final isLast = index == _achievements.length - 1;
                      return Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: achievement.isCompleted
                                  ? achievement.color
                                  : AppColors.primaryWhite,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: achievement.isCompleted
                                    ? achievement.color
                                    : AppColors.primaryBlack.withOpacity(0.3),
                                width: 3,
                              ),
                              boxShadow: achievement.isCompleted
                                  ? [
                                      BoxShadow(
                                        color: achievement.color.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: achievement.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.primaryWhite,
                                      size: 24,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: AppColors.primaryBlack,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 4,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: achievement.isCompleted
                                      ? [
                                          achievement.color,
                                          _achievements[index + 1].isCompleted
                                              ? _achievements[index + 1].color
                                              : AppColors.primaryBlack.withOpacity(0.2),
                                        ]
                                      : [
                                          AppColors.primaryBlack.withOpacity(0.2),
                                          AppColors.primaryBlack.withOpacity(0.2),
                                        ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _achievements.isEmpty
                      ? const Center(
                          child: Text('Chưa có thành tích nào'),
                        )
                      : Column(
                          children: _achievements.asMap().entries.map((entry) {
                            final index = entry.key;
                            final achievement = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < _achievements.length - 1 ? 20 : 0,
                              ),
                              child: AchievementCard(
                                achievement: achievement,
                                index: index,
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

