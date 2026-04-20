import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/pages/account_form.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/category_detail_state.dart';
import 'package:wisebuget/features/analytics/presentation/pages/category_detail_page.dart';
import 'package:wisebuget/features/budget/presentation/pages/budget_list_page.dart';
import 'package:wisebuget/features/category/presentation/pages/categories_page.dart';
import 'package:wisebuget/features/settings/presentation/pages/currency_picker_page.dart';
import 'package:wisebuget/features/settings/presentation/pages/language_picker_page.dart';
import 'package:wisebuget/features/settings/presentation/pages/launch_page_picker_page.dart';
import 'package:wisebuget/features/settings/presentation/pages/theme_picker_page.dart';
import 'package:wisebuget/core/app/main_shell.dart';
import 'package:wisebuget/features/settings/presentation/pages/settings_page.dart';

class HomeRouter {
  static final routes = <GoRoute>[
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: MainShell()),
    ),
    GoRoute(
      path: AppRoutes.manageCategories,
      builder: (context, state) => const CategoriesPage(),
    ),
    GoRoute(
      path: AppRoutes.accountForm,
      builder: (context, state) {
        final account = state.extra as AccountEntity?;
        return AccountForm(account: account);
      },
    ),

    GoRoute(
      path: AppRoutes.budgets,
      builder: (context, state) => const BudgetListPage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.settingsCurrency,
      builder: (context, state) => const CurrencyPickerPage(),
    ),
    GoRoute(
      path: AppRoutes.settingsLanguage,
      builder: (context, state) => const LanguagePickerPage(),
    ),
    GoRoute(
      path: AppRoutes.settingsTheme,
      builder: (context, state) => const ThemePickerPage(),
    ),
    GoRoute(
      path: AppRoutes.settingsLaunchPage,
      builder: (context, state) => const LaunchPagePickerPage(),
    ),
    GoRoute(
      path: AppRoutes.categoryDetail,
      builder: (context, state) {
        final args = state.extra as CategoryDetailArgs;
        return CategoryDetailPage(args: args);
      },
    ),
  ];
}
