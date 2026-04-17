import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/pages/categories_page.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_state.dart';
import 'package:wisebuget/features/settings/presentation/widgets/section_label.dart';
import 'package:wisebuget/features/settings/presentation/widgets/settings_card.dart';
import 'package:wisebuget/features/settings/presentation/widgets/settings_tile.dart';
import 'package:wisebuget/features/settings/presentation/widgets/settings_tile_toggle.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _faceIdEnabled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final languageName = _languageName(state.locale?.languageCode);
        final themeName = _themeName(l10n, state.themeMode);

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            centerTitle: false,
            title: Text(l10n.settings),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionLabel(label: l10n.general),
              const SizedBox(height: 8),
              SettingsCard(
                items: [
                  SettingsTile(
                    icon: Icons.attach_money_rounded,
                    title: l10n.currency,
                    subtitle: state.currency,
                    isFirst: true,
                    onTap: () => context.push(AppRoutes.settingsCurrency),
                  ),
                  SettingsTile(
                    icon: Icons.language_rounded,
                    title: l10n.language,
                    subtitle: languageName,
                    onTap: () => context.push(AppRoutes.settingsLanguage),
                  ),
                  SettingsTile(
                    icon: Icons.notifications_rounded,
                    title: l10n.notifications,
                    subtitle: 'On',
                  ),
                  SettingsTile(
                    icon: Icons.grid_view_rounded,
                    title: 'Categories',
                    subtitle: '',
                    isLast: true,
                    onTap: () => showCategoriesModal(context: context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(label: l10n.personalization),
              const SizedBox(height: 8),
              SettingsCard(
                items: [
                  SettingsTile(
                    icon: Icons.palette_rounded,
                    title: l10n.theme,
                    subtitle: themeName,
                    isFirst: true,
                    onTap: () => context.push(AppRoutes.settingsTheme),
                  ),
                  SettingsTile(
                    icon: Icons.rocket_launch_rounded,
                    title: l10n.launchPage,
                    subtitle: _launchPageLabel(state.launchPage, l10n),
                    onTap: () => context.push(AppRoutes.settingsLaunchPage),
                  ),
                  SettingsTileToggle(
                    icon: Icons.face_retouching_natural_rounded,
                    title: l10n.faceId,
                    value: _faceIdEnabled,
                    onChanged: (v) => setState(() => _faceIdEnabled = v),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(label: 'Data'),
              const SizedBox(height: 8),
              SettingsCard(
                items: [
                  SettingsTile(
                    icon: Icons.delete_sweep_rounded,
                    title: 'Clear All Data',
                    subtitle: '',
                    isFirst: true,
                    isLast: true,
                    onTap: () => _confirmClearData(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _languageName(String? code) => switch (code) {
    'ru' => 'Русский',
    'kk' => 'Қазақша',
    _ => 'English',
  };

  String _themeName(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
    ThemeMode.light => l10n.themeLight,
    ThemeMode.dark => l10n.themeDark,
    _ => l10n.themeSystem,
  };

  String _launchPageLabel(String page, AppLocalizations l10n) => switch (page) {
    'accounts' => l10n.accounts,
    'analytics' => l10n.analytics,
    'tools' => 'Tools',
    _ => 'Home',
  };

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all accounts, transactions, budgets, and categories. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SettingsCubit>().clearAllData();
      sl<AccountCubit>().loadAccounts();
      sl<TransactionCubit>().loadTransactions();
      sl<BudgetCubit>().loadBudgets();
      sl<CategoryCubit>().loadCategories();
      if (context.mounted) context.go(AppRoutes.home);
    }
  }
}
