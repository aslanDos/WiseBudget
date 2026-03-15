import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/router/home_router.dart';
import 'package:wisebuget/core/router/onboarding_router.dart';
import 'package:wisebuget/core/router/routes.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    navigatorKey: globalNavigatorKey,
    redirect: (context, state) {
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
      // feature‐specific sub‐routers:
      ...HomeRouter.routes,
      ...OnboardingRouter.routes,
    ],
  );
}
