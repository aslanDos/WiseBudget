import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/layout/app_breakpoints.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/shared/widgets/color_icon_selector.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/widgets/picker_list_tile.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_state.dart';
import 'package:wisebuget/features/budget/presentation/widgets/category_multi_select.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';

const _kBudgetIconOptions = [
  'piggyBank',
  'wallet',
  'coins',
  'creditCard',
  'banknote',
  'trendingUp',
  'utensils',
  'shoppingBag',
  'shoppingCart',
  'car',
  'home',
  'dumbbell',
  'music',
  'heart',
  'coffee',
  'plane',
  'gift',
  'book',
  'stethoscope',
  'star',
  'receipt',
  'globe',
  'laptop',
  'briefCase',
];

Future<bool?> showBudgetFormModal({
  required BuildContext context,
  String? budgetUuid,
  BudgetCubit? budgetCubit,
}) {
  if (budgetCubit != null) {
    return showCupertinoModalBottomSheet<bool>(
      context: context,
      expand: false,
      barrierColor: Colors.black54,
      builder: (context) => BlocProvider.value(
        value: budgetCubit,
        child: BudgetFormSheet(
          budgetUuid: budgetUuid,
          budgetCubit: budgetCubit,
        ),
      ),
    );
  }

  final ownedCubit = sl<BudgetCubit>()..loadBudgets();
  return showCupertinoModalBottomSheet<bool>(
    context: context,
    expand: false,
    barrierColor: Colors.black54,
    builder: (context) => BlocProvider(
      create: (_) => ownedCubit,
      child: BudgetFormSheet(budgetUuid: budgetUuid, budgetCubit: ownedCubit),
    ),
  );
}

class BudgetFormSheet extends StatefulWidget {
  final String? budgetUuid;
  final BudgetCubit budgetCubit;

  const BudgetFormSheet({
    super.key,
    this.budgetUuid,
    required this.budgetCubit,
  });

  bool get isEditing => budgetUuid != null;

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  late String _name;
  late double _amount;
  late BudgetPeriod _period;
  late String _iconCode;
  late int _selectedColorValue;
  late List<String> _selectedCategoryUuids;
  late DateTime? _customStart;
  late DateTime? _customEnd;

  BudgetEntity? _existingBudget;
  bool _isSaving = false;
  late final BudgetCubit _budgetCubit;

  @override
  void initState() {
    super.initState();
    _budgetCubit = widget.budgetCubit;
    final rng = Random();
    sl<AccountCubit>().loadAccounts();
    sl<CategoryCubit>().loadCategories();

    if (widget.isEditing) {
      _loadExisting();
    } else {
      _name = '';
      _amount = 0;
      _period = BudgetPeriod.monthly;
      _iconCode = _kBudgetIconOptions[rng.nextInt(_kBudgetIconOptions.length)];
      _selectedColorValue =
          AppPalette.colors[rng.nextInt(AppPalette.colors.length)];
      _selectedCategoryUuids = [];
      _customStart = null;
      _customEnd = null;
    }
  }

  void _loadExisting() {
    final budget = _budgetCubit.state.budgets
        .where((b) => b.budget.uuid == widget.budgetUuid)
        .firstOrNull
        ?.budget;

    if (budget != null) {
      _existingBudget = budget;
      _name = budget.name;
      _amount = budget.limit;
      _period = budget.period;
      _iconCode = budget.iconCode;
      _selectedColorValue = budget.colorValue;
      _selectedCategoryUuids = List.from(budget.categoryUuids);
      _customStart = budget.startDate;
      _customEnd = budget.endDate;
    } else {
      final rng = Random();
      _name = '';
      _amount = 0;
      _period = BudgetPeriod.monthly;
      _iconCode = _kBudgetIconOptions[rng.nextInt(_kBudgetIconOptions.length)];
      _selectedColorValue =
          AppPalette.colors[rng.nextInt(AppPalette.colors.length)];
      _selectedCategoryUuids = [];
      _customStart = null;
      _customEnd = null;
    }
  }

  bool get _isValid => _name.trim().isNotEmpty && _amount > 0;

  String get _amountDisplay {
    if (_amount == 0) return '0';
    if (_amount == _amount.truncateToDouble()) {
      return _amount.truncate().toString();
    }
    return _amount
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String _periodLabel(AppLocalizations l10n) {
    return switch (_period) {
      BudgetPeriod.weekly => l10n.periodWeekly,
      BudgetPeriod.monthly => l10n.periodMonthly,
      BudgetPeriod.custom =>
        _customStart != null && _customEnd != null
            ? '${DateFormatter.formatShortDate(_customStart!, l10n)} – ${DateFormatter.formatShortDate(_customEnd!, l10n)}'
            : l10n.periodCustom,
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(_selectedColorValue);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _budgetCubit),
        BlocProvider.value(value: sl<CategoryCubit>()),
        BlocProvider.value(value: sl<AccountCubit>()),
      ],
      child: BlocConsumer<BudgetCubit, BudgetState>(
        listenWhen: (prev, cur) =>
            _isSaving &&
            prev.status == CubitStatus.loading &&
            cur.status != CubitStatus.loading,
        listener: (context, state) {
          if (state.status == CubitStatus.success) {
            _isSaving = false;
            Navigator.pop(context, true);
          } else if (state.status == CubitStatus.failure) {
            _isSaving = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? context.l10n.failedToSave),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == CubitStatus.loading;

          return Material(
            color: context.c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= AppBreakpoints.formWide;
                final horizontalPadding =
                    constraints.maxWidth >= AppBreakpoints.comfortablePadding
                    ? 24.0
                    : 16.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 1080 : 760),
                    child: Column(
                      children: [
                        _Header(
                          isEditing: widget.isEditing,
                          onDelete: widget.isEditing
                              ? () => _confirmDelete(context)
                              : null,
                        ),
                        Expanded(
                          child: isWide
                              ? _buildWideLayout(
                                  context: context,
                                  selectedColor: selectedColor,
                                  isLoading: isLoading,
                                  horizontalPadding: horizontalPadding,
                                )
                              : _buildCompactLayout(
                                  context: context,
                                  selectedColor: selectedColor,
                                  isLoading: isLoading,
                                  horizontalPadding: horizontalPadding,
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ── Pickers ──────────────────────────────────────────────────────────────

  Future<void> _showAmountInput(BuildContext context) async {
    final result = await showModalInput(
      context: context,
      initialValue: _amount == 0 ? '' : _amountDisplay,
      hintText: '0.00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    if (result == null) return;

    final normalized = result.replaceAll(',', '.').trim();
    final parsed = double.tryParse(normalized);
    if (parsed != null && parsed >= 0) {
      setState(() => _amount = parsed);
    }
  }

  Future<void> _showPeriodPicker(BuildContext context) async {
    final result = await showModal<(BudgetPeriod, DateTime?, DateTime?)>(
      context: context,
      builder: (ctx) => _PeriodPickerSheet(
        selected: _period,
        customStart: _customStart,
        customEnd: _customEnd,
      ),
    );
    if (result != null) {
      setState(() {
        _period = result.$1;
        _customStart = result.$2;
        _customEnd = result.$3;
      });
    }
  }

  Future<void> _showCategoryPicker(
    BuildContext context,
    List<CategoryEntity> categories,
  ) async {
    final result = await showCategoryMultiSelect(
      context: context,
      categories: categories,
      selectedUuids: _selectedCategoryUuids,
      title: context.l10n.categories,
    );
    if (result != null) {
      setState(() => _selectedCategoryUuids = result);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: context.l10n.deleteBudget,
      message: context.l10n.areYouSureDeleteBudget,
      confirmText: context.l10n.delete,
      isDestructive: true,
    );
    if (confirmed == true) {
      _budgetCubit.deleteBudget(widget.budgetUuid!);
    }
  }

  void _save(BuildContext context) {
    final accountState = sl<AccountCubit>().state;
    final currency = accountState.accounts.isNotEmpty
        ? accountState.accounts.first.currency
        : 'USD';

    final now = DateTime.now();

    setState(() => _isSaving = true);

    if (widget.isEditing && _existingBudget != null) {
      _budgetCubit.editBudget(
        _existingBudget!.copyWith(
          name: _name.trim(),
          limit: _amount,
          currency: currency,
          period: _period,
          startDate: _period == BudgetPeriod.custom
              ? (_customStart ?? now)
              : now,
          endDate: _period == BudgetPeriod.custom ? _customEnd : null,
          categoryUuids: _selectedCategoryUuids,
          iconCode: _iconCode,
          colorValue: _selectedColorValue,
        ),
      );
    } else {
      _budgetCubit.addBudget(
        BudgetEntity(
          uuid: const Uuid().v4(),
          name: _name.trim(),
          limit: _amount,
          currency: currency,
          period: _period,
          startDate: _period == BudgetPeriod.custom
              ? (_customStart ?? now)
              : now,
          endDate: _period == BudgetPeriod.custom ? _customEnd : null,
          categoryUuids: _selectedCategoryUuids,
          accountUuids: const [],
          iconCode: _iconCode,
          colorValue: _selectedColorValue,
          createdDate: now,
        ),
      );
    }
  }

  Widget _buildCompactLayout({
    required BuildContext context,
    required Color selectedColor,
    required bool isLoading,
    required double horizontalPadding,
  }) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildFormContent(
              context: context,
              selectedColor: selectedColor,
              showSelectorFirst: false,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
            horizontalPadding,
            16,
          ),
          child: Button(
            label: context.l10n.save,
            isLoading: isLoading,
            onPressed: _isValid ? () => _save(context) : null,
            width: double.infinity,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
      ],
    );
  }

  Widget _buildWideLayout({
    required BuildContext context,
    required Color selectedColor,
    required bool isLoading,
    required double horizontalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: _buildVisualPanel(
                context: context,
                selectedColor: selectedColor,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.c.surfaceContainer.withAlpha(0x55),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildFieldsOnly(context: context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Button(
                    label: context.l10n.save,
                    isLoading: isLoading,
                    onPressed: _isValid ? () => _save(context) : null,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent({
    required BuildContext context,
    required Color selectedColor,
    required bool showSelectorFirst,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        _buildBudgetPreview(selectedColor: selectedColor),
        const SizedBox(height: 16),
        if (showSelectorFirst) ...[
          _buildVisualPanel(
            context: context,
            selectedColor: selectedColor,
            includePreview: false,
          ),
          const SizedBox(height: 16),
        ],
        _buildFieldsOnly(context: context),
        if (!showSelectorFirst) ...[
          const SizedBox(height: 12),
          ColorIconSelector(
            selectedColorValue: _selectedColorValue,
            selectedIconCode: _iconCode,
            iconOptions: _kBudgetIconOptions,
            onColorChanged: (v) => setState(() => _selectedColorValue = v),
            onIconChanged: (code) => setState(() => _iconCode = code),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildBudgetPreview({required Color selectedColor}) {
    return Center(
      child: ColoredIconBox(
        icon: AppIcons.fromCode(_iconCode),
        color: selectedColor,
        size: 56,
        padding: 20,
        borderRadius: 24,
      ),
    );
  }

  Widget _buildVisualPanel({
    required BuildContext context,
    required Color selectedColor,
    bool includePreview = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer.withAlpha(0x55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (includePreview) ...[
            _buildBudgetPreview(selectedColor: selectedColor),
            const SizedBox(height: 20),
          ],
          ColorIconSelector(
            selectedColorValue: _selectedColorValue,
            selectedIconCode: _iconCode,
            iconOptions: _kBudgetIconOptions,
            onColorChanged: (v) => setState(() => _selectedColorValue = v),
            onIconChanged: (code) => setState(() => _iconCode = code),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsOnly({required BuildContext context}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NameField(name: _name, onChanged: (v) => setState(() => _name = v)),
        const SizedBox(height: 12),
        PickerFieldGroup(
          backgroundColor: context.c.surfaceContainer,
          children: [
            PickerField(
              icon: Icons.account_balance_wallet_outlined,
              label: context.l10n.budgetLimit,
              value: _amountDisplay,
              shrink: false,
              onTap: () => _showAmountInput(context),
            ),
            PickerField(
              icon: AppIcons.calendar,
              label: context.l10n.period,
              value: _periodLabel(context.l10n),
              shrink: false,
              onTap: () => _showPeriodPicker(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, catState) {
            final expenseCategories = catState.categories
                .where(
                  (category) =>
                      category.type == TransactionType.expense &&
                      category.visible,
                )
                .toList();
            final selectedCategories = expenseCategories
                .where(
                  (category) => _selectedCategoryUuids.contains(category.uuid),
                )
                .toList();
            final String? categoryValue = selectedCategories.isEmpty
                ? null
                : selectedCategories.length == 1
                ? selectedCategories.first.name
                : '${selectedCategories.first.name} +(${selectedCategories.length - 1})';

            return PickerField(
              backgroundColor: context.c.surfaceContainer,
              icon: AppIcons.grid,
              label: context.l10n.categories,
              value: categoryValue,
              shrink: false,
              onTap: () => _showCategoryPicker(context, expenseCategories),
            );
          },
        ),
      ],
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onDelete;

  const _Header({required this.isEditing, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.c.onSurface.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            ActionButton(
              icon: AppIcons.close,
              onTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text(
                  isEditing ? context.l10n.editBudget : context.l10n.newBudget,
                  style: context.t.titleMedium,
                ),
              ),
            ),
            if (onDelete != null)
              ActionButton(
                icon: AppIcons.trash,
                onTap: onDelete!,
                iconColor: context.c.error,
              )
            else
              const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Name field ───────────────────────────────────────────────────────────────

class _NameField extends StatelessWidget {
  final String name;
  final ValueChanged<String> onChanged;

  const _NameField({required this.name, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PickerField(
      icon: Icons.text_fields_rounded,
      label: context.l10n.name,
      value: name,
      iconColor: context.c.onSecondary,
      backgroundColor: context.c.surfaceContainer,
      shrink: false,
      onTap: () => _showInput(context),
    );
  }

  Future<void> _showInput(BuildContext context) async {
    final result = await showModalInput(
      context: context,
      initialValue: name,
      hintText: 'Budget name',
      maxLength: BudgetEntity.maxNameLength,
    );
    if (result != null) onChanged(result);
  }
}

// ─── Period picker sheet ──────────────────────────────────────────────────────

class _PeriodPickerSheet extends StatelessWidget {
  final BudgetPeriod selected;
  final DateTime? customStart;
  final DateTime? customEnd;

  const _PeriodPickerSheet({
    required this.selected,
    this.customStart,
    this.customEnd,
  });

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text(context.l10n.period, style: context.t.titleMedium),
      child: ListView(
        shrinkWrap: true,
        children: [
          PickerListTile(
            icon: Icons.calendar_view_week_rounded,
            iconColor: context.c.primary,
            iconBackgroundColor: context.c.primary.withAlpha(0x22),
            title: context.l10n.periodWeekly,
            subtitle: context.l10n.resetsEveryMonday,
            isSelected: selected == BudgetPeriod.weekly,
            onTap: () =>
                Navigator.pop(context, (BudgetPeriod.weekly, null, null)),
          ),
          PickerListTile(
            icon: Icons.calendar_month_rounded,
            iconColor: context.c.primary,
            iconBackgroundColor: context.c.primary.withAlpha(0x22),
            title: context.l10n.periodMonthly,
            subtitle: context.l10n.resetsEveryMonth,
            isSelected: selected == BudgetPeriod.monthly,
            onTap: () =>
                Navigator.pop(context, (BudgetPeriod.monthly, null, null)),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          PickerListTile(
            icon: AppIcons.calendar,
            iconColor: context.c.primary,
            iconBackgroundColor: context.c.primary.withAlpha(0x22),
            title: context.l10n.customRange,
            subtitle: selected == BudgetPeriod.custom && customStart != null
                ? _range(context, customStart!, customEnd)
                : context.l10n.pickStartAndEndDate,
            isSelected: selected == BudgetPeriod.custom,
            onTap: () => _pickCustom(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _range(BuildContext context, DateTime s, DateTime? e) {
    final start = DateFormatter.formatShortDate(s, context.l10n);
    if (e == null) return start;
    return '$start – ${DateFormatter.formatShortDate(e, context.l10n)}';
  }

  Future<void> _pickCustom(BuildContext context) async {
    final initial = (customStart != null && customEnd != null)
        ? DateTimeRange(start: customStart!, end: customEnd!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initial,
    );

    if (picked != null && context.mounted) {
      Navigator.pop(context, (
        BudgetPeriod.custom,
        picked.start,
        DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
      ));
    }
  }
}
