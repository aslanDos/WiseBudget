import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/pages/account_detail_page.dart';
import 'package:wisebuget/features/account/presentation/pages/account_form_page.dart';
import 'package:wisebuget/features/budget/presentation/pages/budget_list_page.dart';
import 'package:wisebuget/features/category/presentation/pages/categories_page.dart';
import 'package:wisebuget/core/app/main_shell.dart';

class HomeRouter {
  static final routes = <GoRoute>[
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: AppRoutes.manageCategories,
      builder: (context, state) => const CategoriesPage(),
    ),
    GoRoute(
      path: AppRoutes.accountDetail,
      builder: (context, state) {
        final account = state.extra as AccountEntity;
        return AccountDetailPage(account: account);
      },
    ),
    GoRoute(
      path: AppRoutes.accountForm,
      builder: (context, state) {
        final account = state.extra as AccountEntity?;
        return AccountFormPage(account: account);
      },
    ),

    GoRoute(
      path: AppRoutes.budgets,
      builder: (context, state) => const BudgetListPage(),
    ),
  ];
}
