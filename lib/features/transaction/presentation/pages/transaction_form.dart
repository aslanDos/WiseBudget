import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/input_amount/input_amount.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_amount_section.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_details_section.dart';
import 'package:wisebuget/features/transaction/presentation/models/transaction_form_data.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_pickers.dart';

Future<bool?> showTransactionFormModal({
  required BuildContext context,
  TransactionType initialType = TransactionType.expense,
  TransactionEntity? transaction,
}) {
  return showCupertinoModalBottomSheet<bool>(
    context: context,
    expand: false,
    barrierColor: Colors.black54,
    builder: (context) => TransactionForm(
      initialType: initialType,
      transaction: transaction,
    ),
  );
}

class TransactionForm extends StatefulWidget {
  final TransactionType initialType;
  final TransactionEntity? transaction;

  const TransactionForm({
    super.key,
    required this.initialType,
    this.transaction,
  });

  bool get isEditing => transaction != null;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  late TransactionFormData _form;
  bool _hasShownAccountPicker = false;
  bool _hasShownToAccountPicker = false;
  bool _hasShownCategoryPicker = false;

  bool get isEditing => widget.isEditing;

  @override
  void initState() {
    super.initState();
    _form = TransactionFormData.fromTransaction(
      widget.transaction,
      widget.initialType,
    );
    if (isEditing) {
      _hasShownAccountPicker = true;
      _hasShownToAccountPicker = true;
      _hasShownCategoryPicker = true;
    }
    _loadData();
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
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FormHeader(
                isEditing: isEditing,
                selectedAccountUuid: _form.accountUuid,
                onAccountSelected: (uuid) =>
                    setState(() => _form.accountUuid = uuid),
                onDelete: () => _showDeleteDialog(context),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypeToggle(),
                    const SizedBox(height: 24),
                    _buildFormContent(),
                  ],
                ),
              ),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return TypeToggle<TransactionType>(
      items: TransactionType.values
          .map((t) => TypeToggleItem(value: t, label: t.label, icon: t.icon))
          .toList(),
      selected: _form.type,
      onChanged: (type) => setState(() => _form.type = type),
      selectedBackgroundColor: (t) => t.actionBackgroundColor(context),
      selectedForegroundColor: (t) => t.actionColor(context),
    );
  }

  Widget _buildFormContent() {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            _autoShowPickers(accountState, categoryState);

            final categories = _form.filterCategories(categoryState.categories);
            final availableToAccounts =
                _form.filterToAccounts(accountState.accounts);

            return Column(
              children: [
                TransactionAmountSection(
                  amount: _form.displayAmount,
                  type: _form.type,
                  onTap: _showAmountInput,
                ),
                const SizedBox(height: 16),
                TransactionDetailsSection(
                  type: _form.type,
                  date: _form.date,
                  note: _form.note,
                  selectedCategory: _form.findSelectedCategory(categoryState.categories),
                  categories: categories,
                  onCategorySelected: (uuid) =>
                      setState(() => _form.categoryUuid = uuid),
                  selectedToAccount: _form.findSelectedToAccount(accountState.accounts),
                  availableToAccounts: availableToAccounts,
                  onToAccountSelected: (uuid) =>
                      setState(() => _form.toAccountUuid = uuid),
                  onDateSelected: (date) => setState(() => _form.date = date),
                  onNoteChanged: (note) => setState(() => _form.note = note),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocConsumer<TransactionCubit, TransactionState>(
        listenWhen: (prev, curr) =>
            prev.status == TransactionStatus.loading &&
            curr.status != TransactionStatus.loading,
        listener: (context, state) {
          if (state.status == TransactionStatus.success) {
            Navigator.pop(context, true);
          } else if (state.status == TransactionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed to save')),
            );
          }
        },
        builder: (context, state) => Button(
          label: isEditing ? 'Save Changes' : 'Add ${_form.type.label}',
          isLoading: state.status == TransactionStatus.loading,
          onPressed: _form.isValidAmount ? () => _saveTransaction(context) : null,
          width: double.infinity,
        ),
      ),
    );
  }

  void _autoShowPickers(AccountState accountState, CategoryState categoryState) {
    if (_form.accountUuid == null && !_hasShownAccountPicker) {
      _hasShownAccountPicker = true;
      if (accountState.accounts.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAccountPicker(
            context: context,
            accounts: accountState.accounts,
            selectedAccountUuid: _form.accountUuid,
            onSelected: (uuid) => setState(() => _form.accountUuid = uuid),
          );
        });
      }
      return;
    }

    if (_form.type == TransactionType.transfer) {
      if (_form.accountUuid != null &&
          _form.toAccountUuid == null &&
          !_hasShownToAccountPicker) {
        _hasShownToAccountPicker = true;
        final available = _form.filterToAccounts(accountState.accounts);
        if (available.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showAccountPicker(
              context: context,
              accounts: available,
              selectedAccountUuid: _form.toAccountUuid,
              onSelected: (uuid) => setState(() => _form.toAccountUuid = uuid),
              title: 'Select Destination Account',
            );
          });
        }
      }
      return;
    }

    final categories = _form.filterCategories(categoryState.categories);
    if (_form.accountUuid != null &&
        _form.categoryUuid == null &&
        !_hasShownCategoryPicker &&
        categories.isNotEmpty) {
      _hasShownCategoryPicker = true;
      // Category picker is handled by TransactionDetailsSection
    }
  }

  Future<void> _showAmountInput() async {
    final result = await showInputAmountSheet(
      context: context,
      initialAmount: _form.amount,
      title: _form.type.label,
    );
    if (result != null) {
      setState(() => _form.amount = result);
    }
  }

  void _saveTransaction(BuildContext context) {
    final error = _form.validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final account = context.read<AccountCubit>().state.accounts.firstWhere(
          (a) => a.uuid == _form.accountUuid,
        );
    final cubit = context.read<TransactionCubit>();
    final categoryUuid = _form.isTransfer ? '' : (_form.categoryUuid ?? '');

    if (isEditing) {
      cubit.editTransaction(
        widget.transaction!.copyWith(
          amount: _form.amount,
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
          amount: _form.amount,
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

  void _showDeleteDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            onPressed: () {
              Navigator.pop(dialogContext);
              sl<TransactionCubit>().removeTransaction(
                widget.transaction!.uuid,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  final bool isEditing;
  final String? selectedAccountUuid;
  final ValueChanged<String> onAccountSelected;
  final VoidCallback onDelete;

  const _FormHeader({
    required this.isEditing,
    required this.selectedAccountUuid,
    required this.onAccountSelected,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
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
            Expanded(child: Center(child: _buildAccountSelector(context))),
            if (isEditing)
              IconButton(
                onPressed: onDelete,
                icon: Icon(AppIcons.trash, color: colorScheme.error),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final account = state.accounts
            .where((a) => a.uuid == selectedAccountUuid)
            .firstOrNull;
        final accountName = account?.name ?? 'Select account';
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return GestureDetector(
          onTap: () => showAccountPicker(
            context: context,
            accounts: state.accounts,
            selectedAccountUuid: selectedAccountUuid,
            onSelected: onAccountSelected,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                accountName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }
}
