import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/app/pages/budget/budget_tab_body.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:wisebuget/features/budget/presentation/pages/budget_form_page.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';

class BudgetTab extends StatefulWidget {
  const BudgetTab({super.key});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  late final BudgetCubit _budgetCubit;

  @override
  void initState() {
    super.initState();
    _budgetCubit = sl<BudgetCubit>();
    _budgetCubit.loadBudgets();
    sl<CategoryCubit>().loadCategories();
  }

  @override
  void dispose() {
    _budgetCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _budgetCubit),
        BlocProvider.value(value: sl<CategoryCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          centerTitle: false,
          title: Text(context.l10n.budgets, style: context.t.headlineMedium),
          actionsPadding: const EdgeInsets.only(right: 16),
          actions: [
            ActionButton(
              icon: AppIcons.add,
              onTap: () => _openBudgetForm(context),
            ),
          ],
        ),
        body: BudgetTabBody(
          onAddBudget: () => _openBudgetForm(context),
          onEditBudget: (uuid) => _openBudgetForm(context, budgetUuid: uuid),
        ),
      ),
    );
  }

  Future<void> _openBudgetForm(
    BuildContext context, {
    String? budgetUuid,
  }) async {
    final result = await showBudgetFormModal(
      context: context,
      budgetUuid: budgetUuid,
      budgetCubit: _budgetCubit,
    );
    if (result == true && mounted) {
      _budgetCubit.loadBudgets();
    }
  }
}
