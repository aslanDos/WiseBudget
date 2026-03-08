import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/features/category/presentation/pages/categories_page.dart';
import 'package:wisebuget/features/home/presentation/pages/home_page.dart';

class HomeRouter {
  static final routes = <GoRoute>[
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.manageCategories,
      builder: (context, state) => const CategoriesPage(),
    ),
  ];
}
