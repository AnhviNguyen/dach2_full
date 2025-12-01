import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/screens/pronunciation_practice_screen.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/screens/free_speak_screen.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/screens/chat_teacher_screen.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/speak_practice_mock_data.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/widgets/section_title.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/widgets/speak_hero_card.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/widgets/speak_stats_row.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/widgets/speak_mission_card.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/widgets/quick_actions_grid.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/widgets/speak_roadmap.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/widgets/coach_card.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/models/quick_action_item.dart';

class SpeakPracticeHomeScreen extends StatelessWidget {
  const SpeakPracticeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quickActions = [
      QuickActionItem(
        title: 'Luyện phát âm chuẩn',
        icon: Icons.record_voice_over,
        color: AppColors.primaryYellow,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PronunciationPracticeScreen()),
        ),
      ),

      QuickActionItem(
        title: 'Nói tự do',
        icon: Icons.mic_none,
        color: AppColors.warning,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FreeSpeakScreen()),
        ),
      ),
      QuickActionItem(
        title: 'Chat với giáo viên',
        icon: Icons.chat_bubble_outline,
        color: AppColors.info,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatTeacherScreen()),
        ),
      ),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.whiteOff),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trung tâm luyện nói',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SpeakHeroCard(
              onPronunciationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PronunciationPracticeScreen()),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Bắt đầu nhanh'),
            const SizedBox(height: 12),
            QuickActionsGrid(actions: quickActions),
            const SizedBox(height: 28),
            const SectionTitle(title: 'Lộ trình luyện nói 4 bước'),
            const SizedBox(height: 12),
            SpeakRoadmap(steps: SpeakPracticeMockData.roadmapSteps),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

