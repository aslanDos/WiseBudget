import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/router/home_router.dart';
import 'package:wisebuget/core/router/routes.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    navigatorKey: globalNavigatorKey,
    routes: [
      // GoRoute for splash
      // feature‐specific sub‐routers:
      ...HomeRouter.routes,
      // ...OnboardingRouter.routes,
    ],
  );
}
