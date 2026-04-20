import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/router/home_router.dart';
import 'package:wisebuget/core/router/onboarding_router.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/features/splash/presentation/pages/splash_page.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: globalNavigatorKey,
    redirect: (context, state) {
      final isSplash = state.matchedLocation == AppRoutes.splash;
      if (isSplash) return null;

      final prefs = sl<LocalPreferences>();
      final completedOnboarding = prefs.completedOnboarding;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (!completedOnboarding && !isOnboarding) {
        return AppRoutes.onboarding;
      }
      if (completedOnboarding && isOnboarding) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashPage()),
      ),
      ...OnboardingRouter.routes,
      ...HomeRouter.routes,
    ],
  );
}
