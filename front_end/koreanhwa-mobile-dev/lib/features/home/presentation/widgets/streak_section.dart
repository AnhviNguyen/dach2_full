import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/streak_stat.dart';
import 'package:koreanhwa_flutter/core/storage/shared_preferences_service.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';

class StreakSection extends ConsumerStatefulWidget {
  final int? userId;
  
  const StreakSection({super.key, this.userId});
  
  @override
  ConsumerState<StreakSection> createState() => _StreakSectionState();
}

class _StreakSectionState extends ConsumerState<StreakSection> {
  int _studyDays = 0;
  int _restDays = 0;
  int _notStudiedDays = 0;
  double _streakProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }
  
  Future<void> _loadStreakData() async {
    final studyDaysSet = await SharedPreferencesService.getStudyDays();
    final now = DateTime.now();
    final vietnamTime = now.toUtc().add(const Duration(hours: 7));
    
    // Calculate days in the last 30 days
    int studyCount = 0;
    int restCount = 0;
    
    for (int i = 0; i < 30; i++) {
      final day = vietnamTime.subtract(Duration(days: i));
      final dayKey = '${day.year}-${day.month}-${day.day}';
      if (studyDaysSet.contains(dayKey)) {
        studyCount++;
      } else {
        restCount++;
      }
    }
    
    final user = ref.read(authProvider).user;
    final currentStreak = user?.streakDays ?? 0;
    final streakProgress = currentStreak > 0 ? (currentStreak / 30.0).clamp(0.0, 1.0) : 0.0;
    
    setState(() {
      _studyDays = studyCount;
      _restDays = restCount;
      _notStudiedDays = 30 - studyCount - restCount;
      _streakProgress = streakProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    const colorOrange = Color(0xFFF97316);
    const colorPink = Color(0xFFEC4899);
    const colorPurple = Color(0xFF8B5CF6);
    final user = ref.watch(authProvider).user;

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
              Text(
                'Streak học tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StreakStat(
                title: 'Ngày học',
                value: '$_studyDays',
                color: colorOrange,
                icon: Icons.check_circle,
              ),
              StreakStat(
                title: 'Ngày nghỉ',
                value: '$_restDays',
                color: colorPink,
                icon: Icons.event_busy,
              ),
              StreakStat(
                title: 'Chưa học',
                value: '$_notStudiedDays',
                color: colorPurple,
                icon: Icons.pending,
              ),
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
              widthFactor: _streakProgress,
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
}

