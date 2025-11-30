import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/blog/presentation/screens/blog_detail_screen.dart';
import 'package:koreanhwa_flutter/features/blog/presentation/screens/blog_manage_screen.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_info_screen.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_join_screen.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_prize_claim_screen.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_prize_pending_screen.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_prize_success_screen.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_result_lose_screen.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_result_win_screen.dart';
import 'package:koreanhwa_flutter/features/courses/presentation/screen/course_detail_screen.dart';
import 'package:koreanhwa_flutter/features/courses/presentation/screen/course_list_screen.dart';
import 'package:koreanhwa_flutter/features/courses/presentation/screen/payment_screen.dart';
import 'package:koreanhwa_flutter/features/home/presentation/screens/home_screen.dart';
import 'package:koreanhwa_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screen/topik_detail_screen.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screen/topik_test_form_screen.dart';
import 'package:koreanhwa_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:koreanhwa_flutter/features/courses/presentation/screen/course_classroom_screen.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/screens/speak_practice_home_screen.dart';
import 'package:koreanhwa_flutter/features/speak_practice/presentation/screens/pronunciation_practice_screen.dart';
import 'package:koreanhwa_flutter/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:koreanhwa_flutter/features/ranking/presentation/screens/ranking_screen.dart';
import 'package:koreanhwa_flutter/features/textbook/presentation/screens/textbook_screen.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/presentation/screens/learning_curriculum_screen.dart';
import 'package:koreanhwa_flutter/features/vocabulary/presentation/screens/vocabulary_screen.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screen/exam_result_screen.dart';
import 'package:koreanhwa_flutter/features/blog/presentation/screens/blog_screen.dart';
import 'package:koreanhwa_flutter/features/blog/presentation/screens/blog_create_screen.dart';
import 'package:koreanhwa_flutter/features/blog/data/models/blog_post.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_screen.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/screens/competition_evaluating_screen.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_result.dart';
import 'package:koreanhwa_flutter/features/roadmap/presentation/screens/roadmap_placement_screen.dart';
import 'package:koreanhwa_flutter/features/roadmap/presentation/screens/roadmap_detail_screen.dart';
import 'package:koreanhwa_flutter/features/roadmap/presentation/screens/roadmap_test_screen.dart';
import 'package:koreanhwa_flutter/features/roadmap/presentation/screens/roadmap_survey_screen.dart';
import 'package:koreanhwa_flutter/features/material/presentation/screens/material_screen.dart';
import 'package:koreanhwa_flutter/features/material/presentation/screens/material_detail_screen.dart';
import 'package:koreanhwa_flutter/services/roadmap_service.dart';
import 'package:koreanhwa_flutter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screens/topik_library_screen.dart';
import 'package:koreanhwa_flutter/features/my_vocabulary/presentation/screens/my_vocabulary_screen.dart';
import 'package:koreanhwa_flutter/features/settings/presentation/screens/settings_screen.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';
import 'package:koreanhwa_flutter/core/storage/app_storage_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isAuthenticated = authState.isAuthenticated;
  final isLoading = authState.isLoading;

  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      // Đợi auth check hoàn thành
      if (isLoading) {
        return '/splash';
      }

      final isOnboardingCompleted = await AppStorageService.isOnboardingCompleted();

      final isOnboarding = state.matchedLocation == '/onboarding';
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';

      // Nếu chưa hoàn thành onboarding và không phải đang ở onboarding
      if (!isOnboardingCompleted && !isOnboarding && !isSplash) {
        return '/onboarding';
      }

      // Nếu đã hoàn thành onboarding nhưng chưa đăng nhập
      if (isOnboardingCompleted && !isAuthenticated && !isLogin && !isRegister && !isSplash) {
        return '/login';
      }

      // Nếu đã đăng nhập và đang ở login/register/onboarding, redirect về home
      if (isAuthenticated && (isLogin || isRegister || isOnboarding)) {
        return '/home';
      }

      // Nếu đang ở splash, redirect dựa trên trạng thái
      if (isSplash) {
        if (!isOnboardingCompleted) {
          return '/onboarding';
        } else if (!isAuthenticated) {
          return '/login';
        } else {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
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
        path: '/blog/:id',
        name: 'blog-detail',
        builder: (context, state) {
          final postId = int.tryParse(state.pathParameters['id'] ?? '');
          if (postId != null) {
            return BlogDetailScreen(postId: postId);
          }
          // Fallback: try to get from extra or query parameter
          final post = state.extra as BlogPost?;
          final queryPostId = int.tryParse(state.uri.queryParameters['id'] ?? '');
          return BlogDetailScreen(
            postId: queryPostId ?? post?.id,
            post: post,
          );
        },
      ),
      GoRoute(
        path: '/blog/detail',
        name: 'blog-detail-alt',
        builder: (context, state) {
          final postId = int.tryParse(state.uri.queryParameters['id'] ?? '');
          final post = state.extra as BlogPost?;
          return BlogDetailScreen(
            postId: postId ?? post?.id,
            post: post,
          );
        },
      ),
      GoRoute(
        path: '/competition',
        name: 'competition',
        builder: (context, state) => const CompetitionScreen(),
      ),
      GoRoute(
        path: '/competition/:id',
        name: 'competition-detail',
        builder: (context, state) {
          final competitionId = int.tryParse(state.pathParameters['id'] ?? '');
          if (competitionId != null) {
            return CompetitionInfoScreen(competitionId: competitionId);
          }
          // Fallback: try to get from extra or query parameter
          final competition = state.extra as Competition?;
          final queryCompetitionId = int.tryParse(state.uri.queryParameters['id'] ?? '');
          return CompetitionInfoScreen(
            competitionId: queryCompetitionId ?? competition?.id,
            competition: competition,
          );
        },
      ),
      GoRoute(
        path: '/competition/info',
        name: 'competition-info',
        builder: (context, state) {
          final competitionId = int.tryParse(state.uri.queryParameters['id'] ?? '');
          final competition = state.extra as Competition?;
          return CompetitionInfoScreen(
            competitionId: competitionId ?? competition?.id,
            competition: competition,
          );
        },
      ),
      GoRoute(
        path: '/competition/join',
        name: 'competition-join',
        builder: (context, state) {
          final competitionId = int.tryParse(state.uri.queryParameters['id'] ?? '');
          final competition = state.extra as Competition?;
          return CompetitionJoinScreen(
            competitionId: competitionId ?? competition?.id,
            competition: competition,
          );
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
      GoRoute(
        path: '/roadmap',
        name: 'roadmap',
        builder: (context, state) {
          if (RoadmapService.hasCompletedPlacement()) {
            return const RoadmapDetailScreen();
          }
          return const RoadmapSurveyScreen();
        },
      ),
      GoRoute(
        path: '/roadmap/survey',
        name: 'roadmap-survey',
        builder: (context, state) => const RoadmapSurveyScreen(),
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
      GoRoute(
        path: '/roadmap/placement',
        name: 'roadmap-placement',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RoadmapPlacementScreen(surveyData: extra);
        },
      ),
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
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  // Listen auth state changes để refresh router
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (previous?.isAuthenticated != next.isAuthenticated && !next.isLoading) {
      // Auth state thay đổi, refresh router để trigger redirect
      router.refresh();
    }
  });

  return router;
});
