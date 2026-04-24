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
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/exchange_rate/domain/usecases/get_or_fetch_exchange_rate.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
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
    ),
  );
}

class TransactionForm extends StatefulWidget {
  final TransactionType initialType;
  final TransactionEntity? transaction;
  final String? initialAccountUuid;
  final DateTime? initialDate;

  const TransactionForm({
    super.key,
    required this.initialType,
    this.transaction,
    this.initialAccountUuid,
    this.initialDate,
  });

  bool get isEditing => transaction != null;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  late TransactionFormEntity _form;
  String _amountString = '';
  // Preserves sign for adjustment transactions when editing.
  late bool _isNegativeAdjustment;

  String? _rateChipLabel;
  bool _rateIsStale = false;

  bool get isEditing => widget.isEditing;

  @override
  void initState() {
    super.initState();
    _form = TransactionFormEntity.fromTransaction(
      widget.transaction,
      widget.initialType,
      initialAccountUuid: widget.initialAccountUuid,
      initialDate: widget.initialDate,
    );
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
                      isEditing: isEditing,
                      selectedAccountUuid: _form.accountUuid,
                      onAccountSelected: (uuid) {
                        setState(() => _form.accountUuid = uuid);
                        _fetchRate();
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

            return BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
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
    return BlocConsumer<TransactionCubit, TransactionState>(
      listenWhen: (prev, curr) =>
          prev.status == CubitStatus.loading &&
          curr.status != CubitStatus.loading,
      listener: (context, state) {
        if (state.status == CubitStatus.success) {
          Navigator.pop(context, true);
        } else if (state.status == CubitStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? context.l10n.failedToSave),
            ),
          );
        }
      },
      builder: (context, state) => Button(
        label: context.l10n.save,
        isLoading: state.status == CubitStatus.loading,
        onPressed: _form.isValidAmount ? () => _saveTransaction(context) : null,
        width: double.infinity,
      ),
    );
  }

  // Future<void> _navigateToCategoryManager(BuildContext context) async {
  //   final result = await context.push(AppRoutes.manageCategories);
  //   if (result == true && context.mounted) {
  //     context.read<CategoryCubit>().loadCategories();
  //   }
  // }

  void _saveTransaction(BuildContext context) {
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
    final categoryUuid = _form.isTransfer || _form.isAdjustment
        ? ''
        : (_form.categoryUuid ?? '');
    // Preserve direction for adjustment: negative adjustments stay negative.
    final amount = _form.isAdjustment && _isNegativeAdjustment
        ? -_form.amount
        : _form.amount;

    if (isEditing) {
      cubit.editTransaction(
        widget.transaction!.copyWith(
          amount: amount,
          currency: account.currency,
          type: _form.type,
          categoryUuid: categoryUuid,
          accountUuid: _form.accountUuid,
          toAccountUuid: _form.toAccountUuid,
          note: _form.note.isEmpty ? null : _form.note,
          date: _form.date,
        ),
      );
    } else {
      cubit.addTransaction(
        TransactionEntity(
          uuid: const Uuid().v4(),
          amount: amount,
          currency: account.currency,
          type: _form.type,
          categoryUuid: categoryUuid,
          accountUuid: _form.accountUuid!,
          toAccountUuid: _form.toAccountUuid,
          note: _form.note.isEmpty ? null : _form.note,
          date: _form.date,
          createdDate: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
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
