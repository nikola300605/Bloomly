import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bloomly/features/auth/screens/login_screen.dart';
import 'package:bloomly/features/home/screens/home_screen.dart';
import 'package:bloomly/features/plant_detail/screens/plant_detail_screen.dart';
import 'package:bloomly/features/add_plant/screens/add_plant_screen.dart';
import 'package:bloomly/features/add_plant/screens/plant_search_screen.dart';
import 'package:bloomly/features/scan/screens/scan_camera_screen.dart';
import 'package:bloomly/features/scan/screens/scan_symptoms_screen.dart';
import 'package:bloomly/features/scan/screens/scan_results_screen.dart';
import 'package:bloomly/features/recommendations/screens/quiz_screen.dart';
import 'package:bloomly/features/recommendations/screens/results_screen.dart';
import 'package:bloomly/features/notifications/screens/care_schedule_screen.dart';
import 'package:bloomly/features/community/screens/community_feed_screen.dart';
import 'package:bloomly/features/community/screens/article_screen.dart';
import 'package:bloomly/features/community/screens/write_article_screen.dart';
import 'package:bloomly/features/profile/screens/profile_screen.dart';
import 'package:bloomly/shared/widgets/bloomly_bottom_nav.dart';

/// Global messenger key so infrastructure code (e.g. the API client's
/// session-expiry handler) can show snackbars without a BuildContext.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Named route constants
abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const plantDetail = '/plants/:plantId';
  static const addPlant = '/add-plant';
  static const plantSearch = '/add-plant/search';
  static const scan = '/scan';
  static const scanSymptoms = '/scan/symptoms';
  static const scanResults = '/scan/results';
  static const quiz = '/quiz';
  static const quizResults = '/quiz/results';
  static const careSchedule = '/care-schedule';
  static const community = '/community';
  static const article = '/articles/:articleId';
  static const writeArticle = '/articles/write';
  static const profile = '/profile';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),

    // Shell route — persistent bottom nav for Plants / Community / Profile
    ShellRoute(
      builder: (context, state, child) => BloomlyBottomNav(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'plants/:plantId',
              builder: (_, state) => PlantDetailScreen(
                plantId: state.pathParameters['plantId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.community,
          builder: (_, __) => const CommunityFeedScreen(),
          routes: [
            GoRoute(
              path: 'articles/:articleId',
              builder: (_, state) => ArticleScreen(
                articleId: state.pathParameters['articleId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, __) => const ProfileScreen(),
        ),
      ],
    ),

    // Full-screen flows pushed on top of the shell
    GoRoute(
      path: AppRoutes.addPlant,
      builder: (_, __) => const AddPlantScreen(),
    ),
    GoRoute(
      path: AppRoutes.plantSearch,
      builder: (_, __) => const PlantSearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.scan,
      builder: (_, state) => ScanCameraScreen(
        mode: state.uri.queryParameters['mode'] ?? 'identify',
        plantId: state.uri.queryParameters['plantId'],
      ),
    ),
    GoRoute(
      path: AppRoutes.scanSymptoms,
      builder: (_, state) => ScanSymptomsScreen(
        photoPath: state.extra as String? ?? '',
        plantId: state.uri.queryParameters['plantId'],
      ),
    ),
    GoRoute(
      path: AppRoutes.scanResults,
      builder: (_, state) => ScanResultsScreen(
        result: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),
    GoRoute(
      path: AppRoutes.quiz,
      builder: (_, __) => const QuizScreen(),
    ),
    GoRoute(
      path: AppRoutes.quizResults,
      builder: (_, state) => QuizResultsScreen(
        answers: state.extra as Map<String, dynamic>? ?? {},
      ),
    ),
    GoRoute(
      path: AppRoutes.careSchedule,
      builder: (_, __) => const CareScheduleScreen(),
    ),
    GoRoute(
      path: AppRoutes.writeArticle,
      builder: (_, __) => const WriteArticleScreen(),
    ),
  ],
);
