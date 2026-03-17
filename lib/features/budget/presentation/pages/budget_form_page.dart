import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/input_amount/input_amount.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_state.dart';
import 'package:wisebuget/features/budget/presentation/widgets/account_multi_select.dart';
import 'package:wisebuget/features/budget/presentation/widgets/category_multi_select.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';

/// Shows the budget form as a modal bottom sheet.
///
/// Returns `true` if a budget was created/updated, `null` if dismissed.
Future<bool?> showBudgetFormModal({
  required BuildContext context,
  String? budgetUuid,
}) {
  return showCupertinoModalBottomSheet<bool>(
    context: context,
    expand: true,
    builder: (context) => BudgetFormSheet(budgetUuid: budgetUuid),
  );
}

class BudgetFormSheet extends StatefulWidget {
  final String? budgetUuid;

  const BudgetFormSheet({super.key, this.budgetUuid});

  bool get isEditing => budgetUuid != null;

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  final _nameController = TextEditingController();

  double _amount = 0;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  List<String> _selectedCategoryUuids = [];
  List<String> _selectedAccountUuids = [];
  String _iconCode = 'pie_chart';
  int _colorValue = AppPalette.colors.first;

  BudgetEntity? _existingBudget;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.isEditing) {
      _loadExistingBudget();
    }
  }

  void _loadData() {
    sl<AccountCubit>().loadAccounts();
    sl<CategoryCubit>().loadCategories();
  }

  void _loadExistingBudget() {
    final budgetState = sl<BudgetCubit>().state;
    final budgetProgress = budgetState.budgets
        .where((b) => b.budget.uuid == widget.budgetUuid)
        .firstOrNull;

    if (budgetProgress != null) {
      final budget = budgetProgress.budget;
      _existingBudget = budget;
      _nameController.text = budget.name;
      _amount = budget.limit;
      _selectedPeriod = budget.period;
      _selectedCategoryUuids = List.from(budget.categoryUuids);
      _selectedAccountUuids = List.from(budget.accountUuids);
      _iconCode = budget.iconCode;
      _colorValue = budget.colorValue;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _displayAmount {
    if (_amount == 0) return '0';
    if (_amount == _amount.truncate()) {
      return _amount.truncate().toString();
    }
    return _amount.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  bool get _isValidAmount => _amount > 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<BudgetCubit>()),
        BlocProvider.value(value: sl<AccountCubit>()),
        BlocProvider.value(value: sl<CategoryCubit>()),
      ],
      child: Material(
        color: colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 24.0),
                      _buildAmountSection(),
                      const SizedBox(height: 24.0),
                      _buildPeriodSelector(),
                      const SizedBox(height: 24.0),
                      _buildCategoriesSection(),
                      const SizedBox(height: 16.0),
                      _buildAccountsSection(),
                    ],
                  ),
                ),
              ),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(0x40),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(AppIcons.close),
            ),
            Expanded(
              child: Center(
                child: Text(
                  widget.isEditing ? 'Edit Budget' : 'New Budget',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (widget.isEditing)
              IconButton(
                onPressed: () => _showDeleteDialog(context),
                icon: Icon(AppIcons.trash, color: colorScheme.error),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = AppPalette.fromValue(_colorValue, defaultColor: colorScheme.primary);

    return Row(
      children: [
        // Icon picker
        GestureDetector(
          onTap: _showIconPicker,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(0x26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              AppIcons.fromCode(_iconCode),
              size: 28,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Name field
        Expanded(
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Budget name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withAlpha(0x80),
            ),
            style: theme.textTheme.titleMedium,
            maxLength: BudgetEntity.maxNameLength,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending Limit',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showAmountInput,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(0x80),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '\$$_displayAmount',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TypeToggle<BudgetPeriod>(
          items: [
            TypeToggleItem(
              value: BudgetPeriod.monthly,
              label: 'Monthly',
              icon: Icons.calendar_month,
            ),
            TypeToggleItem(
              value: BudgetPeriod.weekly,
              label: 'Weekly',
              icon: Icons.calendar_view_week,
            ),
          ],
          selected: _selectedPeriod,
          onChanged: (period) => setState(() => _selectedPeriod = period),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        // Only expense categories for budgets
        final expenseCategories = state.categories
            .where((c) => c.type == TransactionType.expense && c.visible)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _selectedCategoryUuids.isEmpty
                      ? 'All categories'
                      : '${_selectedCategoryUuids.length} selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CategoryChips(
              categories: expenseCategories,
              selectedUuids: _selectedCategoryUuids,
              onTap: () => _showCategoryPicker(expenseCategories),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountsSection() {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        return PickerFieldGroup(
          children: [
            PickerField(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Accounts',
              value: _selectedAccountUuids.isEmpty
                  ? 'All accounts'
                  : '${_selectedAccountUuids.length} selected',
              padding: const EdgeInsets.all(16),
              onTap: () => _showAccountPicker(state.accounts),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAmountInput() async {
    final result = await showInputAmountSheet(
      context: context,
      initialAmount: _amount,
      title: 'Budget Limit',
    );
    if (result != null) {
      setState(() => _amount = result);
    }
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocConsumer<BudgetCubit, BudgetState>(
        listenWhen: (previous, current) =>
            previous.status == BudgetStatus.loading &&
            current.status != BudgetStatus.loading,
        listener: (context, state) {
          if (state.status == BudgetStatus.success) {
            Navigator.pop(context, true);
          } else if (state.status == BudgetStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed to save')),
            );
          }
        },
        builder: (context, state) => Button(
          label: widget.isEditing ? 'Save Changes' : 'Create Budget',
          isLoading: state.status == BudgetStatus.loading,
          onPressed: _isValidAmount && _nameController.text.isNotEmpty
              ? () => _saveBudget(context)
              : null,
          width: double.infinity,
        ),
      ),
    );
  }

  // Pickers
  void _showIconPicker() {
    // Simple implementation - could be expanded
    final icons = [
      'pie_chart',
      'restaurant',
      'local_cafe',
      'directions_car',
      'shopping_cart',
      'home',
      'flight',
      'movie',
      'fitness_center',
      'school',
      'medical_services',
      'pets',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => GridView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final iconCode = icons[index];
          final isSelected = iconCode == _iconCode;

          return GestureDetector(
            onTap: () {
              setState(() => _iconCode = iconCode);
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                AppIcons.fromCode(iconCode),
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCategoryPicker(List categories) async {
    final result = await showCategoryMultiSelect(
      context: context,
      categories: categories.cast(),
      selectedUuids: _selectedCategoryUuids,
    );

    if (result != null) {
      setState(() => _selectedCategoryUuids = result);

      // Auto-set name and icon from first category if single selection
      if (result.length == 1 && _nameController.text.isEmpty) {
        final category = categories.firstWhere((c) => c.uuid == result.first);
        _nameController.text = category.name;
        _iconCode = category.iconCode;
        _colorValue = category.colorValue ?? _colorValue;
        setState(() {});
      }
    }
  }

  Future<void> _showAccountPicker(List accounts) async {
    final result = await showAccountMultiSelect(
      context: context,
      accounts: accounts.cast(),
      selectedUuids: _selectedAccountUuids,
    );

    if (result != null) {
      setState(() => _selectedAccountUuids = result);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text(
          'Are you sure you want to delete this budget?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              sl<BudgetCubit>().deleteBudget(widget.budgetUuid!);
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveBudget(BuildContext context) {
    final error = _validateForm();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final accountState = sl<AccountCubit>().state;
    final currency = accountState.accounts.isNotEmpty
        ? accountState.accounts.first.currency
        : 'USD';

    final cubit = sl<BudgetCubit>();

    if (widget.isEditing && _existingBudget != null) {
      cubit.editBudget(
        _existingBudget!.copyWith(
          name: _nameController.text.trim(),
          limit: _amount,
          currency: currency,
          period: _selectedPeriod,
          categoryUuids: _selectedCategoryUuids,
          accountUuids: _selectedAccountUuids,
          iconCode: _iconCode,
          colorValue: _colorValue,
        ),
      );
    } else {
      cubit.addBudget(
        BudgetEntity(
          uuid: const Uuid().v4(),
          name: _nameController.text.trim(),
          limit: _amount,
          currency: currency,
          period: _selectedPeriod,
          startDate: DateTime.now(),
          categoryUuids: _selectedCategoryUuids,
          accountUuids: _selectedAccountUuids,
          iconCode: _iconCode,
          colorValue: _colorValue,
          createdDate: DateTime.now(),
        ),
      );
    }
  }

  String? _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      return 'Please enter a budget name';
    }
    if (_amount <= 0) {
      return 'Please enter a valid limit';
    }
    return null;
  }
}
