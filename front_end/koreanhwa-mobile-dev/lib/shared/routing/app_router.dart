import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/screens/home_screen.dart';
import 'package:koreanhwa_flutter/screens/login_screen.dart';
import 'package:koreanhwa_flutter/screens/onboarding_screen.dart';
import 'package:koreanhwa_flutter/screens/register_screen.dart';
import 'package:koreanhwa_flutter/screens/course_detail_screen.dart';
import 'package:koreanhwa_flutter/screens/course_list_screen.dart';
import 'package:koreanhwa_flutter/screens/payment_screen.dart';
import 'package:koreanhwa_flutter/screens/course_classroom_screen.dart';
import 'package:koreanhwa_flutter/screens/speak_pratice/speak_practice_home_screen.dart';
import 'package:koreanhwa_flutter/screens/speak_pratice/pronunciation_practice_screen.dart';
import 'package:koreanhwa_flutter/screens/speak_pratice/conversation_practice_screen.dart';
import 'package:koreanhwa_flutter/screens/achievements_screen.dart';
import 'package:koreanhwa_flutter/screens/ranking_screen.dart';
import 'package:koreanhwa_flutter/screens/textbook_screen.dart';
import 'package:koreanhwa_flutter/screens/learning_curriculum_screen.dart';
import 'package:koreanhwa_flutter/screens/vocabulary_screen.dart';
import 'package:koreanhwa_flutter/screens/topik/topik_library_screen.dart';
import 'package:koreanhwa_flutter/screens/topik/topik_detail_screen.dart';
import 'package:koreanhwa_flutter/screens/topik/topik_test_form_screen.dart';
import 'package:koreanhwa_flutter/screens/topik/exam_result_screen.dart';
import 'package:koreanhwa_flutter/screens/my_vocabulary/my_vocabulary_screen.dart';
import 'package:koreanhwa_flutter/screens/blog/blog_screen.dart';
import 'package:koreanhwa_flutter/screens/blog/blog_create_screen.dart';
import 'package:koreanhwa_flutter/screens/blog/blog_manage_screen.dart';
import 'package:koreanhwa_flutter/screens/blog/blog_detail_screen.dart';
import 'package:koreanhwa_flutter/models/blog_model.dart';
import 'package:koreanhwa_flutter/screens/competition/competition_screen.dart';
import 'package:koreanhwa_flutter/screens/competition/competition_info_screen.dart';
import 'package:koreanhwa_flutter/screens/competition/competition_join_screen.dart';
import 'package:koreanhwa_flutter/screens/competition/competition_evaluating_screen.dart';
import 'package:koreanhwa_flutter/screens/competition/competition_result_win_screen.dart';
import 'package:koreanhwa_flutter/screens/competition/competition_result_lose_screen.dart';
import 'package:koreanhwa_flutter/screens/competition/competition_prize_claim_screen.dart';
import 'package:koreanhwa_flutter/screens/competition/competition_prize_pending_screen.dart';
import 'package:koreanhwa_flutter/screens/competition/competition_prize_success_screen.dart';
import 'package:koreanhwa_flutter/models/competition_model.dart';
import 'package:koreanhwa_flutter/screens/roadmap/roadmap_placement_screen.dart';
import 'package:koreanhwa_flutter/screens/roadmap/roadmap_detail_screen.dart';
import 'package:koreanhwa_flutter/screens/roadmap/roadmap_test_screen.dart';
import 'package:koreanhwa_flutter/screens/material/material_screen.dart';
import 'package:koreanhwa_flutter/screens/material/material_detail_screen.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';
import 'package:koreanhwa_flutter/screens/settings/settings_screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/course-detail',
      name: 'course-detail',
      builder: (context, state) => const CourseDetailScreen(),
    ),
    GoRoute(
      path: '/courses',
      name: 'courses',
      builder: (context, state) => const CourseListScreen(),
    ),
    GoRoute(
      path: '/lessons',
      name: 'lessons',
      builder: (context, state) => const CourseListScreen(),
    ),
    GoRoute(
      path: '/payment',
      name: 'payment',
      builder: (context, state) {
        final courseTitle = state.uri.queryParameters['courseTitle'] ?? 'Khóa học';
        final amount = double.tryParse(state.uri.queryParameters['amount'] ?? '') ?? 0;
        return PaymentScreen(
          courseTitle: courseTitle,
          amount: amount,
        );
      },
    ),
    GoRoute(
      path: '/course-classroom',
      name: 'course-classroom',
      builder: (context, state) {
        final courseTitle = state.uri.queryParameters['courseTitle'] ?? 'Lớp học';
        return CourseClassroomScreen(courseTitle: courseTitle);
      },
    ),
    GoRoute(
      path: '/achievements',
      name: 'achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/ranking',
      name: 'ranking',
      builder: (context, state) => const RankingScreen(),
    ),
    GoRoute(
      path: '/textbook',
      name: 'textbook',
      builder: (context, state) => const TextbookScreen(),
    ),
    GoRoute(
      path: '/learning-curriculum',
      name: 'learning-curriculum',
      builder: (context, state) {
        final bookId = int.tryParse(state.uri.queryParameters['bookId'] ?? '1') ?? 1;
        final lessonId = int.tryParse(state.uri.queryParameters['lessonId'] ?? '1') ?? 1;
        final bookTitle = state.uri.queryParameters['bookTitle'] ?? 'Giáo trình';
        return LearningCurriculumScreen(
          bookId: bookId,
          lessonId: lessonId,
          bookTitle: bookTitle,
        );
      },
    ),
    GoRoute(
      path: '/vocabulary',
      name: 'vocabulary',
      builder: (context, state) {
        final bookId = int.tryParse(state.uri.queryParameters['bookId'] ?? '1') ?? 1;
        final lessonId = int.tryParse(state.uri.queryParameters['lessonId'] ?? '1') ?? 1;
        return VocabularyScreen(
          bookId: bookId,
          lessonId: lessonId,
        );
      },
    ),
    GoRoute(
      path: '/topik-library',
      name: 'topik-library',
      builder: (context, state) => const TopikLibraryScreen(),
    ),
    GoRoute(
      path: '/topik-detail',
      name: 'topik-detail',
      builder: (context, state) {
        final examId = state.uri.queryParameters['examId'] ?? '';
        final examTitle = state.uri.queryParameters['examTitle'] ?? '';
        return TopikDetailScreen(
          examId: examId,
          examTitle: examTitle,
        );
      },
    ),
    GoRoute(
      path: '/topik-test',
      name: 'topik-test',
      builder: (context, state) {
        final examId = state.uri.queryParameters['examId'] ?? '';
        final examTitle = state.uri.queryParameters['examTitle'] ?? '';
        final isFullTest = state.uri.queryParameters['isFullTest'] == 'true';
        // Note: In real app, parse selectedSections and timeLimit from params
        return TopikTestFormScreen(
          examId: examId,
          examTitle: examTitle,
          isFullTest: isFullTest,
          selectedSections: {'listening': true, 'reading': true},
          timeLimit: '',
        );
      },
    ),
    GoRoute(
      path: '/exam-result',
      name: 'exam-result',
      builder: (context, state) {
        final examId = state.uri.queryParameters['examId'] ?? '';
        final examTitle = state.uri.queryParameters['examTitle'] ?? '';
        // Note: In real app, parse answers and questions from state
        return ExamResultScreen(
          examId: examId,
          examTitle: examTitle,
          answers: {},
          questions: [],
        );
      },
    ),
    GoRoute(
      path: '/my-vocabulary',
      name: 'my-vocabulary',
      builder: (context, state) => const MyVocabularyScreen(),
    ),
    GoRoute(
      path: '/blog',
      name: 'blog',
      builder: (context, state) => const BlogScreen(),
    ),
    GoRoute(
      path: '/blog/create',
      name: 'blog-create',
      builder: (context, state) => const CreateBlogScreen(),
    ),
    GoRoute(
      path: '/blog/manage',
      name: 'blog-manage',
      builder: (context, state) => const BlogManageScreen(),
    ),
    GoRoute(
      path: '/blog/detail',
      name: 'blog-detail',
      builder: (context, state) {
        final post = state.extra as BlogPost?;
        return BlogDetailScreen(post: post);
      },
    ),
    // Competition Routes
    GoRoute(
      path: '/competition',
      name: 'competition',
      builder: (context, state) => const CompetitionScreen(),
    ),
    GoRoute(
      path: '/competition/info',
      name: 'competition-info',
      builder: (context, state) {
        final competition = state.extra as Competition?;
        return CompetitionInfoScreen(competition: competition);
      },
    ),
    GoRoute(
      path: '/competition/join',
      name: 'competition-join',
      builder: (context, state) {
        final competition = state.extra as Competition?;
        return CompetitionJoinScreen(competition: competition);
      },
    ),
    GoRoute(
      path: '/competition/evaluating',
      name: 'competition-evaluating',
      builder: (context, state) {
        final competition = state.extra as Competition?;
        return CompetitionEvaluatingScreen(competition: competition);
      },
    ),
    GoRoute(
      path: '/competition/result-win',
      name: 'competition-result-win',
      builder: (context, state) {
        final result = state.extra as CompetitionResult?;
        return CompetitionResultWinScreen(result: result);
      },
    ),
    GoRoute(
      path: '/competition/result-lose',
      name: 'competition-result-lose',
      builder: (context, state) {
        final result = state.extra as CompetitionResult?;
        return CompetitionResultLoseScreen(result: result);
      },
    ),
    GoRoute(
      path: '/competition/prize-claim',
      name: 'competition-prize-claim',
      builder: (context, state) {
        final result = state.extra as CompetitionResult?;
        return CompetitionPrizeClaimScreen(result: result);
      },
    ),
    GoRoute(
      path: '/competition/prize-pending',
      name: 'competition-prize-pending',
      builder: (context, state) {
        final result = state.extra as CompetitionResult?;
        return CompetitionPrizePendingScreen(result: result);
      },
    ),
    GoRoute(
      path: '/competition/prize-success',
      name: 'competition-prize-success',
      builder: (context, state) {
        final result = state.extra as CompetitionResult?;
        return CompetitionPrizeSuccessScreen(result: result);
      },
    ),
    // Roadmap Routes
    GoRoute(
      path: '/roadmap',
      name: 'roadmap',
      builder: (context, state) {
        // Check if user has completed placement test
        if (RoadmapService.hasCompletedPlacement()) {
          return const RoadmapDetailScreen();
        }
        return const RoadmapPlacementScreen();
      },
    ),
    GoRoute(
      path: '/roadmap/detail',
      name: 'roadmap-detail',
      builder: (context, state) => const RoadmapDetailScreen(),
    ),
    GoRoute(
      path: '/roadmap/test',
      name: 'roadmap-test',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RoadmapTestScreen(extra: extra);
      },
    ),
    // Material Routes
    GoRoute(
      path: '/material',
      name: 'material',
      builder: (context, state) => const MaterialScreen(),
    ),
    GoRoute(
      path: '/material/detail',
      name: 'material-detail',
      builder: (context, state) {
        final materialId = int.tryParse(state.uri.queryParameters['id'] ?? '0') ?? 0;
        return MaterialDetailScreen(materialId: materialId);
      },
    ),
    GoRoute(
      path: '/speak-practice',
      name: 'speak-practice',
      builder: (context, state) => const SpeakPracticeHomeScreen(),
    ),
    GoRoute(
      path: '/speak-practice/pronunciation',
      name: 'speak-practice-pronunciation',
      builder: (context, state) => const PronunciationPracticeScreen(),
    ),
    GoRoute(
      path: '/speak-practice/conversation',
      name: 'speak-practice-conversation',
      builder: (context, state) => const ConversationPracticeScreen(),
    ),
    // Settings Route
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);


