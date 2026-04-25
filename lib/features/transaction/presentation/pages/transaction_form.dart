import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/core/shared/layout/app_breakpoints.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/exchange_rate/domain/usecases/get_or_fetch_exchange_rate.dart';
import 'package:wisebuget/features/transaction/domain/recurrence_frequency.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_state.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/numpad.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/amount_display.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_sheet_header.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_details.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_form_entity.dart';

Future<bool?> showTransactionFormModal({
  required BuildContext context,
  TransactionType initialType = TransactionType.expense,
  TransactionEntity? transaction,
  String? initialAccountUuid,
  DateTime? initialDate,
  bool isDraft = false,
  RecurringTransactionEntity? recurringTemplate,
}) {
  return showCupertinoModalBottomSheet<bool>(
    context: context,
    expand: false,
    barrierColor: Colors.black54,
    builder: (context) => TransactionForm(
      initialType: initialType,
      transaction: transaction,
      initialAccountUuid: initialAccountUuid,
      initialDate: initialDate,
      isDraft: isDraft,
      recurringTemplate: recurringTemplate,
    ),
  );
}

class TransactionForm extends StatefulWidget {
  final TransactionType initialType;
  final TransactionEntity? transaction;
  final String? initialAccountUuid;
  final DateTime? initialDate;
  final bool isDraft;
  final RecurringTransactionEntity? recurringTemplate;

  const TransactionForm({
    super.key,
    required this.initialType,
    this.transaction,
    this.initialAccountUuid,
    this.initialDate,
    this.isDraft = false,
    this.recurringTemplate,
  });

  bool get isEditing => transaction != null && !isDraft;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  late TransactionFormEntity _form;
  String _amountString = '';
  // Preserves sign for adjustment transactions when editing.
  late bool _isNegativeAdjustment;
  bool _isSavingEditWithRecurring = false;
  bool _isDeletingRecurring = false;
  bool _transactionSaveCompleted = false;
  bool _recurringSaveCompleted = false;

  String? _rateChipLabel;
  bool _rateIsStale = false;

  bool get isEditing => widget.isEditing;
  bool get _canDelete => isEditing || widget.recurringTemplate != null;
  bool get _isRecurringDraft => !isEditing && widget.recurringTemplate != null;

  @override
  void initState() {
    super.initState();
    _form = TransactionFormEntity.fromTransaction(
      widget.transaction,
      widget.initialType,
      initialAccountUuid: widget.initialAccountUuid,
      initialDate: widget.initialDate,
    );
    final recurringTemplate = widget.recurringTemplate;
    if (recurringTemplate != null) {
      _form.isRecurring = true;
      _form.recurrenceFrequency = recurringTemplate.frequency;
    }
    _isNegativeAdjustment = _form.isAdjustment && (_form.amount < 0);
    final displayAmount = _form.isAdjustment
        ? _form.amount.abs()
        : _form.amount;
    if (displayAmount > 0) {
      _amountString = displayAmount
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'\.?0+$'), '');
    }
    _loadData();
    _fetchRate();
  }

  Future<void> _fetchRate() async {
    final baseCurrency = sl<LocalPreferences>().currency;
    final accounts = sl<AccountCubit>().state.accounts;
    final account = accounts
        .where((a) => a.uuid == _form.accountUuid)
        .firstOrNull;
    if (account == null) return;

    final accountCurrency = account.currency;
    if (accountCurrency == baseCurrency) {
      if (mounted) setState(() => _rateChipLabel = null);
      return;
    }

    final result = await sl<GetOrFetchExchangeRate>()(
      GetOrFetchRateParams(
        from: accountCurrency,
        to: baseCurrency,
        date: DateTime.now(),
      ),
    );

    if (!mounted) return;
    result.fold((_) => setState(() => _rateChipLabel = null), (entity) {
      if (entity == null) {
        setState(() => _rateChipLabel = null);
        return;
      }
      final rate = entity.rate;
      final formatted = _formatRate(rate);
      setState(() {
        _rateChipLabel = '1 $accountCurrency ≈ $formatted $baseCurrency';
        _rateIsStale = entity.isStale;
      });
    });
  }

  String _formatRate(double rate) {
    if (rate >= 10000) return rate.toStringAsFixed(0);
    if (rate >= 100) return rate.toStringAsFixed(1);
    if (rate >= 1) return rate.toStringAsFixed(2);
    if (rate >= 0.01) return rate.toStringAsFixed(4);
    return rate.toStringAsFixed(6);
  }

  void _onNumpadKey(String key) {
    if (key == '.') {
      if (_amountString.contains('.')) return;
      if (_amountString.isEmpty) _amountString = '0';
    } else if (_amountString == '0') {
      _amountString = '';
    }
    setState(() {
      _amountString += key;
      _form.amount = double.tryParse(_amountString) ?? 0;
    });
  }

  void _onBackspace() {
    if (_amountString.isEmpty) return;
    setState(() {
      _amountString = _amountString.substring(0, _amountString.length - 1);
      _form.amount = double.tryParse(_amountString) ?? 0;
    });
  }

  void _onClear() {
    setState(() {
      _amountString = '';
      _form.amount = 0;
    });
  }

  void _loadData() {
    sl<AccountCubit>().loadAccounts();
    sl<CategoryCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<TransactionCubit>()),
        BlocProvider.value(value: sl<RecurringTransactionCubit>()),
        BlocProvider.value(value: sl<AccountCubit>()),
        BlocProvider.value(value: sl<CategoryCubit>()),
      ],
      child: Material(
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
                    TransactionSheetHeader(
                      isEditing: _canDelete,
                      selectedAccountUuid: _form.accountUuid,
                      isRecurringEnabled: _form.isRecurring,
                      recurrenceFrequency: _form.recurrenceFrequency,
                      onAccountSelected: (uuid) {
                        setState(() => _form.accountUuid = uuid);
                        _fetchRate();
                      },
                      onRecurrenceChanged: (frequency) {
                        setState(() {
                          _form.isRecurring = frequency != null;
                          if (frequency != null) {
                            _form.recurrenceFrequency = frequency;
                          }
                        });
                      },
                      onDelete: () => _showDeleteDialog(context),
                    ),
                    if (!_form.isAdjustment)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 18,
                        ),
                        child: _buildTypeToggle(),
                      ),
                    Expanded(
                      child: isWide
                          ? _buildWideLayout(
                              context: context,
                              horizontalPadding: horizontalPadding,
                            )
                          : _buildCompactLayout(
                              context: context,
                              horizontalPadding: horizontalPadding,
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactLayout({
    required BuildContext context,
    required double horizontalPadding,
  }) {
    return Column(
      children: [
        Expanded(child: _buildAmountSection()),
        _buildDetailsPanel(
          context: context,
          horizontalPadding: horizontalPadding,
          roundedTopOnly: true,
          includeNumpad: true,
          includeBottomInset: true,
          fillHeight: false,
        ),
      ],
    );
  }

  Widget _buildWideLayout({
    required BuildContext context,
    required double horizontalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildAmountSection()),
                const SizedBox(height: 16),
                _buildNumpadCard(),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 6,
            child: _buildDetailsPanel(
              context: context,
              horizontalPadding: horizontalPadding,
              roundedTopOnly: false,
              includeNumpad: false,
              includeBottomInset: false,
              fillHeight: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, accountState) {
              final account = accountState.accounts
                  .where((a) => a.uuid == _form.accountUuid)
                  .firstOrNull;
              final currency =
                  account?.currency ?? sl<LocalPreferences>().currency;
              return AmountDisplay(
                amount: _amountString.isEmpty ? '0' : _amountString,
                type: _form.type,
                currency: currency,
              );
            },
          ),
        ),
        if (_rateChipLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RateChip(label: _rateChipLabel!, isStale: _rateIsStale),
          ),
      ],
    );
  }

  Widget _buildDetailsPanel({
    required BuildContext context,
    required double horizontalPadding,
    required bool roundedTopOnly,
    required bool includeNumpad,
    required bool includeBottomInset,
    required bool fillHeight,
  }) {
    final borderRadius = roundedTopOnly
        ? const BorderRadius.only(
            topRight: Radius.circular(24),
            topLeft: Radius.circular(24),
          )
        : BorderRadius.circular(24);

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        16,
      ),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (fillHeight)
            Expanded(
              child: SingleChildScrollView(
                child: _buildTransactionFields(includeNumpad: includeNumpad),
              ),
            )
          else
            SingleChildScrollView(
              child: _buildTransactionFields(includeNumpad: includeNumpad),
            ),
          const SizedBox(height: 8),
          _buildSaveButton(),
          if (includeBottomInset)
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }

  Widget _buildNumpadCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: _buildNumpad(),
    );
  }

  Widget _buildTransactionFields({required bool includeNumpad}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<AccountCubit, AccountState>(
          builder: (context, accountState) {
            final availableToAccounts = _form.filterToAccounts(
              accountState.accounts,
            );
            _selectInitialToAccountIfNeeded(availableToAccounts);

            return BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                _selectInitialCategoryIfNeeded(categoryState.categories);

                return TransactionDetails(
                  type: _form.type,
                  date: _form.date,
                  note: _form.note,
                  selectedCategory: _form.findSelectedCategory(
                    categoryState.categories,
                  ),
                  categories: _form.filterCategories(categoryState.categories),
                  onCategorySelected: (uuid) =>
                      setState(() => _form.categoryUuid = uuid),
                  selectedToAccount: _form.findSelectedToAccount(
                    accountState.accounts,
                  ),
                  availableToAccounts: availableToAccounts,
                  onToAccountSelected: (uuid) =>
                      setState(() => _form.toAccountUuid = uuid),
                  onDateSelected: (date) => setState(() => _form.date = date),
                  onNoteChanged: (note) => setState(() => _form.note = note),
                );
              },
            );
          },
        ),
        if (includeNumpad) ...[const SizedBox(height: 8), _buildNumpad()],
      ],
    );
  }

  Widget _buildNumpad() {
    return Numpad(
      onKeyPressed: _onNumpadKey,
      onBackspace: _onBackspace,
      onClear: _onClear,
    );
  }

  void _selectInitialCategoryIfNeeded(List<CategoryEntity> categories) {
    if (isEditing) return;
    if (_form.isTransfer || _form.isAdjustment) return;
    if (_form.categoryUuid != null) return;

    final filteredCategories = _form.filterCategories(categories);
    if (filteredCategories.isEmpty) return;

    _form.categoryUuid = filteredCategories.first.uuid;
  }

  void _selectInitialToAccountIfNeeded(List<AccountEntity> accounts) {
    if (isEditing) return;
    if (!_form.isTransfer) return;
    if (_form.toAccountUuid != null) return;
    if (accounts.isEmpty) return;

    _form.toAccountUuid = accounts.first.uuid;
  }

  Widget _buildTypeToggle() {
    return TypeToggle<TransactionType>(
      items: TransactionType.values
          .where((t) => t != TransactionType.adjustment)
          .map(
            (t) => TypeToggleItem(
              value: t,
              label: t.label,
              icon: t.icon,

              selectedBackgroundColor: t.backgroundColor,
              selectedForegroundColor: t.backgroundColor,
            ),
          )
          .toList(),
      selected: _form.type,
      onChanged: (type) => setState(() => _form.type = type),
    );
  }

  Widget _buildSaveButton() {
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionCubit, TransactionState>(
          listenWhen: (prev, curr) =>
              prev.status == CubitStatus.loading &&
              curr.status != CubitStatus.loading,
          listener: (context, state) {
            if (_isDeletingRecurring) {
              if (state.status == CubitStatus.success) {
                _isDeletingRecurring = false;
                Navigator.pop(context, true);
              } else if (state.status == CubitStatus.failure) {
                _isDeletingRecurring = false;
                _showSaveError(
                  context,
                  state.errorMessage ?? context.l10n.failedToSave,
                );
              }
              return;
            }

            if (_isSavingEditWithRecurring) {
              if (state.status == CubitStatus.success) {
                _transactionSaveCompleted = true;
                _completeEditWithRecurringIfReady(context);
              } else if (state.status == CubitStatus.failure) {
                _resetEditWithRecurringState();
                _showSaveError(
                  context,
                  state.errorMessage ?? context.l10n.failedToSave,
                );
              }
              return;
            }

            if (_form.isRecurring) return;
            if (state.status == CubitStatus.success) {
              Navigator.pop(context, true);
            } else if (state.status == CubitStatus.failure) {
              _showSaveError(
                context,
                state.errorMessage ?? context.l10n.failedToSave,
              );
            }
          },
        ),
        BlocListener<RecurringTransactionCubit, RecurringTransactionState>(
          listenWhen: (prev, curr) =>
              prev.status == CubitStatus.loading &&
              curr.status != CubitStatus.loading,
          listener: (context, state) {
            if (_isSavingEditWithRecurring) {
              if (state.status == CubitStatus.success) {
                _recurringSaveCompleted = true;
                _completeEditWithRecurringIfReady(context);
              } else if (state.status == CubitStatus.failure) {
                _resetEditWithRecurringState();
                _showSaveError(
                  context,
                  state.errorMessage ?? context.l10n.failedToSave,
                );
              }
              return;
            }

            if (!_form.isRecurring || isEditing) return;
            if (state.status == CubitStatus.success) {
              Navigator.pop(context, true);
            } else if (state.status == CubitStatus.failure) {
              _showSaveError(
                context,
                state.errorMessage ?? context.l10n.failedToSave,
              );
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final transactionState = context.watch<TransactionCubit>().state;
          final recurringState = context
              .watch<RecurringTransactionCubit>()
              .state;
          final isLoading = _isSavingEditWithRecurring
              ? transactionState.status == CubitStatus.loading ||
                    recurringState.status == CubitStatus.loading
              : _form.isRecurring
              ? recurringState.status == CubitStatus.loading
              : transactionState.status == CubitStatus.loading;

          final label = _isRecurringDraft
              ? context.l10n.confirm
              : _form.isRecurring
              ? isEditing
                    ? context.l10n.saveAndSchedule
                    : context.l10n.saveRecurring
              : context.l10n.save;

          return Button(
            label: label,
            isLoading: isLoading,
            onPressed: _form.isValidAmount
                ? () => _saveTransaction(context)
                : null,
            width: double.infinity,
          );
        },
      ),
    );
  }

  // Future<void> _navigateToCategoryManager(BuildContext context) async {
  //   final result = await context.push(AppRoutes.manageCategories);
  //   if (result == true && context.mounted) {
  //     context.read<CategoryCubit>().loadCategories();
  //   }
  // }

  Future<void> _saveTransaction(BuildContext context) async {
    final error = _form.validate();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final account = context.read<AccountCubit>().state.accounts.firstWhere(
      (a) => a.uuid == _form.accountUuid,
    );
    final cubit = context.read<TransactionCubit>();
    final recurringCubit = context.read<RecurringTransactionCubit>();
    final categoryUuid = _form.isTransfer || _form.isAdjustment
        ? ''
        : (_form.categoryUuid ?? '');
    // Preserve direction for adjustment: negative adjustments stay negative.
    final amount = _form.isAdjustment && _isNegativeAdjustment
        ? -_form.amount
        : _form.amount;
    final recurringTemplate = _resolveRecurringTemplate(context);

    final transaction = TransactionEntity(
      uuid: isEditing ? widget.transaction!.uuid : const Uuid().v4(),
      amount: amount,
      currency: account.currency,
      type: _form.type,
      categoryUuid: categoryUuid,
      accountUuid: _form.accountUuid!,
      toAccountUuid: _form.toAccountUuid,
      note: _form.note.isEmpty ? null : _form.note,
      date: _form.date,
      createdDate: isEditing ? widget.transaction!.createdDate : DateTime.now(),
      recurringTemplateUuid:
          recurringTemplate?.uuid ?? widget.transaction?.recurringTemplateUuid,
    );

    if (isEditing && recurringTemplate != null) {
      final scope = await _showRecurringEditScopeDialog(context);
      if (!context.mounted || scope == null) return;
      _saveRecurringEdit(
        context: context,
        scope: scope,
        transaction: transaction,
        recurringTemplate: recurringTemplate,
      );
      return;
    }

    if (_form.isRecurring) {
      final recurring = RecurringTransactionEntity(
        uuid: const Uuid().v4(),
        amount: amount,
        currency: account.currency,
        type: _form.type,
        categoryUuid: categoryUuid,
        accountUuid: _form.accountUuid!,
        toAccountUuid: _form.toAccountUuid,
        note: _form.note.isEmpty ? null : _form.note,
        startDate: _form.date,
        createdDate: DateTime.now(),
        frequency: _form.recurrenceFrequency,
      );

      if (isEditing) {
        _isSavingEditWithRecurring = true;
        _transactionSaveCompleted = false;
        _recurringSaveCompleted = false;
        recurringCubit.addRecurringTransaction(recurring);
      } else {
        recurringCubit.addRecurringTransaction(recurring);
        return;
      }
    }

    if (isEditing) {
      cubit.editTransaction(transaction);
      return;
    }

    cubit.addTransaction(transaction);
  }

  RecurringTransactionEntity _recurringTemplateFromTransaction({
    required String uuid,
    required TransactionEntity transaction,
    required RecurrenceFrequency frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdDate,
    bool isActive = true,
  }) {
    return RecurringTransactionEntity(
      uuid: uuid,
      amount: transaction.amount,
      currency: transaction.currency,
      type: transaction.type,
      categoryUuid: transaction.categoryUuid,
      accountUuid: transaction.accountUuid,
      toAccountUuid: transaction.toAccountUuid,
      note: transaction.note,
      startDate: startDate ?? transaction.date,
      endDate: endDate,
      createdDate: createdDate ?? DateTime.now(),
      frequency: frequency,
      isActive: isActive,
    );
  }

  Future<_RecurringEditScope?> _showRecurringEditScopeDialog(
    BuildContext context,
  ) {
    return showAppActionDialog<_RecurringEditScope>(
      context: context,
      title: context.l10n.editRepeatingTransaction,
      message: context.l10n.editRepeatingTransactionMessage,
      actions: [
        AppDialogAction<_RecurringEditScope>(
          text: context.l10n.cancel,
          value: null,
        ),
        AppDialogAction<_RecurringEditScope>(
          text: context.l10n.onlyThisTransaction,
          value: _RecurringEditScope.onlyThis,
        ),
        AppDialogAction<_RecurringEditScope>(
          text: context.l10n.futureTransactions,
          value: _RecurringEditScope.future,
        ),
        AppDialogAction<_RecurringEditScope>(
          text: context.l10n.entireSeries,
          value: _RecurringEditScope.entireSeries,
        ),
      ],
    );
  }

  void _saveRecurringEdit({
    required BuildContext context,
    required _RecurringEditScope scope,
    required TransactionEntity transaction,
    required RecurringTransactionEntity recurringTemplate,
  }) {
    final transactionCubit = context.read<TransactionCubit>();
    final recurringCubit = context.read<RecurringTransactionCubit>();

    switch (scope) {
      case _RecurringEditScope.onlyThis:
        transactionCubit.editTransaction(
          transaction.copyWith(clearRecurringTemplateUuid: true),
        );
      case _RecurringEditScope.future:
        final newTemplateUuid = const Uuid().v4();
        final previousEndDate = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day - 1,
        );
        recurringCubit.updateRecurringTransaction(
          recurringTemplate.copyWith(endDate: previousEndDate),
        );
        recurringCubit.addRecurringTransaction(
          _recurringTemplateFromTransaction(
            uuid: newTemplateUuid,
            transaction: transaction,
            frequency: recurringTemplate.frequency,
          ),
        );
        transactionCubit.editTransaction(
          transaction.copyWith(recurringTemplateUuid: newTemplateUuid),
        );
      case _RecurringEditScope.entireSeries:
        recurringCubit.updateRecurringTransaction(
          _recurringTemplateFromTransaction(
            uuid: recurringTemplate.uuid,
            transaction: transaction,
            frequency: recurringTemplate.frequency,
            startDate: recurringTemplate.startDate,
            endDate: recurringTemplate.endDate,
            createdDate: recurringTemplate.createdDate,
            isActive: recurringTemplate.isActive,
          ),
        );
        transactionCubit.editTransaction(transaction);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final recurringTemplate = _resolveRecurringTemplate(context);
    if (recurringTemplate != null) {
      await _showRecurringDeleteDialog(
        context,
        recurringTemplate,
        transactionUuid: isEditing ? widget.transaction!.uuid : null,
      );
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: context.l10n.deleteTransaction,
      message: context.l10n.areYouSureDeleteTransaction,
      confirmText: context.l10n.delete,
      isDestructive: true,
    );

    if (confirmed == true) {
      sl<TransactionCubit>().removeTransaction(widget.transaction!.uuid);
    }
  }

  RecurringTransactionEntity? _resolveRecurringTemplate(BuildContext context) {
    if (widget.recurringTemplate != null) return widget.recurringTemplate;
    final recurringTemplateUuid = widget.transaction?.recurringTemplateUuid;
    if (recurringTemplateUuid == null) return null;

    return context
        .read<RecurringTransactionCubit>()
        .state
        .transactions
        .where((template) => template.uuid == recurringTemplateUuid)
        .firstOrNull;
  }

  Future<void> _showRecurringDeleteDialog(
    BuildContext context,
    RecurringTransactionEntity recurringTemplate, {
    String? transactionUuid,
  }) async {
    final action = await showAppActionDialog<_RecurringDeleteAction>(
      context: context,
      title: context.l10n.repeatingTransaction,
      message: context.l10n.repeatingTransactionDeleteMessage,
      actions: [
        AppDialogAction<_RecurringDeleteAction>(
          text: context.l10n.cancel,
          value: null,
        ),
        AppDialogAction<_RecurringDeleteAction>(
          text: context.l10n.stopRepeat,
          value: _RecurringDeleteAction.stopRepeat,
        ),
        AppDialogAction<_RecurringDeleteAction>(
          text: context.l10n.deleteSeries,
          value: _RecurringDeleteAction.deleteSeries,
          isDestructive: true,
        ),
      ],
    );

    switch (action) {
      case _RecurringDeleteAction.stopRepeat:
        _isDeletingRecurring = true;
        sl<RecurringTransactionCubit>().updateRecurringTransaction(
          recurringTemplate.copyWith(isActive: false),
        );
      case _RecurringDeleteAction.deleteSeries:
        _isDeletingRecurring = true;
        sl<RecurringTransactionCubit>().removeRecurringTransaction(
          recurringTemplate.uuid,
        );
        final transactionCubit = sl<TransactionCubit>();
        final linkedTransactions = transactionCubit.state.transactions
            .where(
              (transaction) =>
                  transaction.recurringTemplateUuid == recurringTemplate.uuid ||
                  transaction.uuid == transactionUuid,
            )
            .toList();
        for (final transaction in linkedTransactions) {
          transactionCubit.removeTransaction(transaction.uuid);
        }
      case null:
        break;
    }
  }

  void _completeEditWithRecurringIfReady(BuildContext context) {
    if (!_transactionSaveCompleted || !_recurringSaveCompleted) return;
    _resetEditWithRecurringState();
    Navigator.pop(context, true);
  }

  void _resetEditWithRecurringState() {
    _isSavingEditWithRecurring = false;
    _isDeletingRecurring = false;
    _transactionSaveCompleted = false;
    _recurringSaveCompleted = false;
  }

  void _showSaveError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({required this.label, required this.isStale});

  final String label;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final color = isStale
        ? const Color(0xFFF59E0B)
        : context.c.onSurface.withAlpha(0x60);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(0x18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isStale) ...[
            Icon(Icons.access_time_rounded, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: context.t.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

enum _RecurringDeleteAction { stopRepeat, deleteSeries }

enum _RecurringEditScope { onlyThis, future, entireSeries }
