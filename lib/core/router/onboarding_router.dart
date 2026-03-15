import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/features/onboarding/presentation/pages/onboarding_page.dart';

class OnboardingRouter {
  static final routes = <GoRoute>[
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
  ];
}
