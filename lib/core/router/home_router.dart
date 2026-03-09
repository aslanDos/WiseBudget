import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/pages/account_detail_page.dart';
import 'package:wisebuget/features/account/presentation/pages/account_form_page.dart';
import 'package:wisebuget/features/category/presentation/pages/categories_page.dart';
import 'package:wisebuget/features/home/presentation/pages/home_page.dart';
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form_page.dart';

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
      path: AppRoutes.transactionForm,
      builder: (context, state) {
        final type = state.extra as TransactionType? ?? TransactionType.expense;
        return TransactionFormPage(initialType: type);
      },
    ),
  ];
}
