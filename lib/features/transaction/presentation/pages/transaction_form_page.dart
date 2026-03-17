import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/input_amount/input_amount.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/amount_display.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_pickers.dart';

/// Shows the transaction form as a modal bottom sheet.
///
/// Returns `true` if a transaction was created/updated, `null` if dismissed.
Future<bool?> showTransactionFormModal({
  required BuildContext context,
  TransactionType initialType = TransactionType.expense,
  TransactionEntity? transaction,
}) {
  return showCupertinoModalBottomSheet<bool>(
    context: context,
    expand: true,
    builder: (context) => TransactionFormSheet(
      initialType: initialType,
      transaction: transaction,
    ),
  );
}

class TransactionFormSheet extends StatefulWidget {
  final TransactionType initialType;
  final TransactionEntity? transaction;

  const TransactionFormSheet({
    super.key,
    required this.initialType,
    this.transaction,
  });

  bool get isEditing => transaction != null;

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  late TransactionType _selectedType;
  double _amount = 0;
  String? _selectedAccountUuid;
  String? _selectedToAccountUuid; // For transfers: destination account
  String? _selectedIncomeCategoryUuid;
  String? _selectedExpenseCategoryUuid;
  late DateTime _selectedDate;
  String _note = '';

  bool _hasShownAccountPicker = false;
  bool _hasShownToAccountPicker = false;
  bool _hasShownCategoryPicker = false;

  // Getter for current type's category
  String? get _selectedCategoryUuid {
    return _selectedType == TransactionType.income
        ? _selectedIncomeCategoryUuid
        : _selectedExpenseCategoryUuid;
  }

  // Setter for current type's category
  set _selectedCategoryUuid(String? uuid) {
    if (_selectedType == TransactionType.income) {
      _selectedIncomeCategoryUuid = uuid;
    } else {
      _selectedExpenseCategoryUuid = uuid;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _loadData();
  }

  void _initializeFormData() {
    final tx = widget.transaction;
    _selectedType = tx?.type ?? widget.initialType;
    _amount = tx?.amount ?? 0;
    _note = tx?.note ?? '';
    _selectedAccountUuid = tx?.accountUuid;
    _selectedToAccountUuid = tx?.toAccountUuid;
    _selectedDate = tx?.date ?? DateTime.now();

    // Set category based on transaction type
    if (tx != null) {
      if (tx.type == TransactionType.income) {
        _selectedIncomeCategoryUuid = tx.categoryUuid;
      } else {
        _selectedExpenseCategoryUuid = tx.categoryUuid;
      }
    }

    // For editing, mark pickers as already shown
    if (widget.isEditing) {
      _hasShownAccountPicker = true;
      _hasShownToAccountPicker = true;
      _hasShownCategoryPicker = true;
    }
  }

  void _loadData() {
    sl<AccountCubit>().loadAccounts();
    sl<CategoryCubit>().loadCategories();
  }

  void _showInitialAccountPicker(List<AccountEntity> accounts) {
    if (_hasShownAccountPicker || accounts.isEmpty) return;
    _hasShownAccountPicker = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAccountPicker(
        context: context,
        accounts: accounts,
        selectedAccountUuid: _selectedAccountUuid,
        onSelected: (uuid) {
          setState(() => _selectedAccountUuid = uuid);
        },
      );
    });
  }

  void _showInitialToAccountPicker(List<AccountEntity> accounts) {
    if (_hasShownToAccountPicker ||
        _selectedAccountUuid == null ||
        accounts.isEmpty ||
        _selectedType != TransactionType.transfer) {
      return;
    }
    _hasShownToAccountPicker = true;

    // Filter out the source account
    final availableAccounts = accounts
        .where((a) => a.uuid != _selectedAccountUuid)
        .toList();
    if (availableAccounts.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAccountPicker(
        context: context,
        accounts: availableAccounts,
        selectedAccountUuid: _selectedToAccountUuid,
        onSelected: (uuid) {
          setState(() => _selectedToAccountUuid = uuid);
        },
        title: 'Select Destination Account',
      );
    });
  }

  void _showInitialCategoryPicker(List<CategoryEntity> categories) {
    if (_hasShownCategoryPicker ||
        _selectedAccountUuid == null ||
        categories.isEmpty ||
        _selectedType == TransactionType.transfer) {
      return;
    }
    _hasShownCategoryPicker = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCategoryPickerModal(categories);
    });
  }

  void _showCategoryPickerModal(List<CategoryEntity> categories) {
    final colorScheme = Theme.of(context).colorScheme;

    showModal(
      context: context,
      builder: (context) => ModalSheet.scrollable(
        title: const Text('Select Category'),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.uuid == _selectedCategoryUuid;
            final color = AppPalette.fromValue(
              category.colorValue,
              defaultColor: colorScheme.primary,
            );

            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withAlpha(0x33),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(AppIcons.fromCode(category.iconCode), color: color),
              ),
              title: Text(category.name),
              trailing: isSelected
                  ? Icon(Icons.check, color: colorScheme.primary)
                  : null,
              onTap: () {
                setState(() => _selectedCategoryUuid = category.uuid);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  String get _displayAmount {
    if (_amount == 0) return '0';
    // Format with up to 2 decimal places, removing trailing zeros
    if (_amount == _amount.truncate()) {
      return _amount.truncate().toString();
    }
    return _amount.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<TransactionCubit>()),
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
                    children: [
                      _buildTypeToggle(),
                      const SizedBox(height: 24.0),
                      _buildFormContent(),
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
            Expanded(child: Center(child: _buildAccountSelector())),
            if (widget.isEditing)
              IconButton(
                onPressed: () => _showDeleteDialog(context),
                icon: Icon(AppIcons.trash, color: colorScheme.error),
              )
            else
              const SizedBox(width: 48), // Balance the close button
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return TypeToggle<TransactionType>(
      items: TransactionType.values
          .map((t) => TypeToggleItem(value: t, label: t.label, icon: t.icon))
          .toList(),
      selected: _selectedType,
      onChanged: (type) => setState(() => _selectedType = type),
      selectedBackgroundColor: (t) => t.actionBackgroundColor(context),
      selectedForegroundColor: (t) => t.actionColor(context),
    );
  }

  Widget _buildAccountSelector() {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        final accountName = _getAccountName(accountState);
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return GestureDetector(
          onTap: () => showAccountPicker(
            context: context,
            accounts: accountState.accounts,
            selectedAccountUuid: _selectedAccountUuid,
            onSelected: (uuid) => setState(() => _selectedAccountUuid = uuid),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18.0,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8.0),
              Text(
                accountName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4.0),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20.0,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormContent() {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            _autoSelectDefaults(accountState, categoryState);

            final (categoryName, selectedCategory, categories) =
                _getCategoryData(categoryState);

            final (toAccountName, selectedToAccount, availableToAccounts) =
                _getToAccountData(accountState);

            return Column(
              children: [
                GestureDetector(
                  onTap: _showAmountInput,
                  child: AmountDisplay(amount: _displayAmount, type: _selectedType),
                ),
                const SizedBox(height: 16.0),
                TransactionPickers(
                  selectedType: _selectedType,
                  selectedCategory: selectedCategory,
                  categoryName: categoryName,
                  selectedDate: _selectedDate,
                  note: _note,
                  categories: categories,
                  // Transfer-specific
                  selectedToAccount: selectedToAccount,
                  toAccountName: toAccountName,
                  availableToAccounts: availableToAccounts,
                  onCategorySelected: (uuid) =>
                      setState(() => _selectedCategoryUuid = uuid),
                  onDateSelected: (date) =>
                      setState(() => _selectedDate = date),
                  onNoteChanged: (note) => setState(() => _note = note),
                  onToAccountSelected: (uuid) =>
                      setState(() => _selectedToAccountUuid = uuid),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAmountInput() async {
    final result = await showInputAmountSheet(
      context: context,
      initialAmount: _amount,
      title: _selectedType.label,
    );
    if (result != null) {
      setState(() => _amount = result);
    }
  }

  bool get _isValidAmount => _amount > 0;

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocConsumer<TransactionCubit, TransactionState>(
        listenWhen: (previous, current) =>
            previous.status == TransactionStatus.loading &&
            current.status != TransactionStatus.loading,
        listener: _handleTransactionState,
        builder: (context, state) => Button(
          label: widget.isEditing
              ? 'Save Changes'
              : 'Add ${_selectedType.label}',

          isLoading: state.status == TransactionStatus.loading,
          onPressed: _isValidAmount ? () => _saveTransaction(context) : null,
          width: double.infinity,
        ),
        // ),
      ),
    );
  }

  // Data helpers
  void _autoSelectDefaults(
    AccountState accountState,
    CategoryState categoryState,
  ) {
    // Show account picker first if no account selected
    if (_selectedAccountUuid == null && !_hasShownAccountPicker) {
      _showInitialAccountPicker(accountState.accounts);
      return;
    }

    // For transfers: show "To Account" picker after source account is selected
    if (_selectedType == TransactionType.transfer) {
      if (_selectedAccountUuid != null &&
          _selectedToAccountUuid == null &&
          !_hasShownToAccountPicker) {
        _showInitialToAccountPicker(accountState.accounts);
      }
      return;
    }

    // For income/expense: show category picker after account is selected
    final categories = _getFilteredCategories(categoryState);
    if (_selectedAccountUuid != null &&
        _selectedCategoryUuid == null &&
        !_hasShownCategoryPicker) {
      _showInitialCategoryPicker(categories);
    }
  }

  String _getAccountName(AccountState state) {
    if (_selectedAccountUuid == null) return 'Select account';
    final account = state.accounts
        .where((a) => a.uuid == _selectedAccountUuid)
        .firstOrNull;
    return account?.name ?? 'Select account';
  }

  (String, CategoryEntity?, List<CategoryEntity>) _getCategoryData(
    CategoryState state,
  ) {
    final categories = _getFilteredCategories(state);
    final selected = categories
        .where((c) => c.uuid == _selectedCategoryUuid)
        .firstOrNull;
    final name = selected?.name ?? 'Select category';
    return (name, selected, categories);
  }

  List<CategoryEntity> _getFilteredCategories(CategoryState state) {
    final type = _selectedType == TransactionType.income
        ? TransactionType.income
        : TransactionType.expense;
    return state.categories.where((c) => c.type == type && c.visible).toList();
  }

  (String, AccountEntity?, List<AccountEntity>) _getToAccountData(
    AccountState state,
  ) {
    // Filter out the source account from available destinations
    final availableAccounts = state.accounts
        .where((a) => a.uuid != _selectedAccountUuid)
        .toList();
    final selected = availableAccounts
        .where((a) => a.uuid == _selectedToAccountUuid)
        .firstOrNull;
    final name = selected?.name ?? 'Select destination';
    return (name, selected, availableAccounts);
  }

  // Transaction handling
  void _handleTransactionState(BuildContext context, TransactionState state) {
    if (state.status == TransactionStatus.success) {
      Navigator.pop(context, true);
    } else if (state.status == TransactionStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Failed to save')),
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

  void _saveTransaction(BuildContext context) {
    final error = _validateForm();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final account = context.read<AccountCubit>().state.accounts.firstWhere(
      (a) => a.uuid == _selectedAccountUuid,
    );

    final cubit = context.read<TransactionCubit>();

    // For transfers, categoryUuid can be empty since we don't need a category
    final categoryUuid = _selectedType == TransactionType.transfer
        ? ''
        : (_selectedCategoryUuid ?? '');

    if (widget.isEditing) {
      cubit.editTransaction(
        widget.transaction!.copyWith(
          amount: _amount,
          currency: account.currency,
          type: _selectedType,
          categoryUuid: categoryUuid,
          accountUuid: _selectedAccountUuid,
          toAccountUuid: _selectedToAccountUuid,
          note: _note.isEmpty ? null : _note,
          date: _selectedDate,
        ),
      );
    } else {
      cubit.addTransaction(
        TransactionEntity(
          uuid: const Uuid().v4(),
          amount: _amount,
          currency: account.currency,
          type: _selectedType,
          categoryUuid: categoryUuid,
          accountUuid: _selectedAccountUuid!,
          toAccountUuid: _selectedToAccountUuid,
          note: _note.isEmpty ? null : _note,
          date: _selectedDate,
          createdDate: DateTime.now(),
        ),
      );
    }
  }

  String? _validateForm() {
    if (_amount <= 0) {
      return 'Please enter a valid amount';
    }
    if (_selectedAccountUuid == null) {
      return 'Please select an account';
    }
    if (_selectedType == TransactionType.transfer) {
      if (_selectedToAccountUuid == null) {
        return 'Please select a destination account';
      }
      if (_selectedAccountUuid == _selectedToAccountUuid) {
        return 'Source and destination accounts must be different';
      }
    } else if (_selectedCategoryUuid == null) {
      return 'Please select a category';
    }
    return null;
  }
}
