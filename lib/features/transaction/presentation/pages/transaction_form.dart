import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/numpad.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/amount_display.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/form_header.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_details_section.dart';
import 'package:wisebuget/features/transaction/presentation/models/transaction_form_data.dart';

Future<bool?> showTransactionFormModal({
  required BuildContext context,
  TransactionType initialType = TransactionType.expense,
  TransactionEntity? transaction,
}) {
  return showCupertinoModalBottomSheet<bool>(
    context: context,
    expand: false,
    barrierColor: Colors.black54,
    builder: (context) =>
        TransactionForm(initialType: initialType, transaction: transaction),
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
  String _amountString = '';

  bool get isEditing => widget.isEditing;

  @override
  void initState() {
    super.initState();
    _form = TransactionFormData.fromTransaction(
      widget.transaction,
      widget.initialType,
    );
    if (_form.amount > 0) {
      _amountString = _form.amount
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'\.?0+$'), '');
    }
    _loadData();
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
    // Вынести выше, чтобы не вызывать при каждом build
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<TransactionCubit>()),
        BlocProvider.value(value: sl<AccountCubit>()),
        BlocProvider.value(value: sl<CategoryCubit>()),
      ],
      child: Material(
        child: Column(
          children: [
            FormHeader(
              isEditing: isEditing,
              selectedAccountUuid: _form.accountUuid,
              onAccountSelected: (uuid) =>
                  setState(() => _form.accountUuid = uuid),
              onDelete: () => _showDeleteDialog(context),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: _buildTypeToggle(),
            ),

            Expanded(
              child: AmountDisplay(
                amount: _amountString.isEmpty ? '0' : _amountString,
                type: _form.type,
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: context.c.surfaceContainer,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _builTransactionDetails(),
                  SizedBox(height: 8),
                  _buildSaveButton(),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _builTransactionDetails() {
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

        const SizedBox(height: 8),
        Numpad(
          onKeyPressed: _onNumpadKey,
          onBackspace: _onBackspace,
          onClear: _onClear,
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return TypeToggle<TransactionType>(
      items: TransactionType.values
          // .where((t) => t != TransactionType.transfer)
          .map(
            (t) => TypeToggleItem(
              value: t,
              label: t.label,
              icon: t.icon,
              selectedBackgroundColor: t.actionBackgroundColor(context),
              selectedForegroundColor: t.actionColor(context),
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
            SnackBar(content: Text(state.errorMessage ?? 'Failed to save')),
          );
        }
      },
      builder: (context, state) => Button(
        label: 'Save',
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

  // Future<void> _showAmountInput() async {
  //   final result = await showInputAmountSheet(
  //     context: context,
  //     initialAmount: _form.amount,
  //     title: _form.type.label,
  //   );
  //   if (result != null) {
  //     setState(() => _form.amount = result);
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

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete Transaction',
      message: 'Are you sure you want to delete this transaction?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      sl<TransactionCubit>().removeTransaction(widget.transaction!.uuid);
    }
  }
}
