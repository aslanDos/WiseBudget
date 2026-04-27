import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
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
import 'package:wisebuget/features/transaction/presentation/actions/transaction_recurring_actions.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_state.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/widgets/top_snack_bar.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_form_content.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_save_button.dart';
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
  late final TransactionRecurringActions _recurringActions;
  final _topSnackBar = TopSnackBarController();
  String _amountString = '';
  // Preserves sign for adjustment transactions when editing.
  late bool _isNegativeAdjustment;
  bool _isSavingEditWithRecurring = false;
  bool _isDeletingRecurring = false;
  bool _transactionSaveCompleted = false;
  bool _recurringSaveCompleted = false;

  String? _rateChipLabel;
  bool _rateIsStale = false;
  int _rateRequestSerial = 0;

  bool get isEditing => widget.isEditing;
  bool get _canDelete => isEditing || widget.recurringTemplate != null;
  bool get _isRecurringDraft => !isEditing && widget.recurringTemplate != null;

  @override
  void initState() {
    super.initState();
    _recurringActions = TransactionRecurringActions(
      transaction: widget.transaction,
      recurringTemplate: widget.recurringTemplate,
    );
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
    _syncInitialSelectionsFromCubitState();
    _fetchRate();
  }

  @override
  void dispose() {
    _topSnackBar.dispose();
    super.dispose();
  }

  Future<void> _fetchRate() async {
    final requestSerial = ++_rateRequestSerial;
    final accountUuid = _form.accountUuid;
    final baseCurrency = sl<LocalPreferences>().currency;
    final accounts = sl<AccountCubit>().state.accounts;
    final account = accounts.where((a) => a.uuid == accountUuid).firstOrNull;
    if (account == null) return;

    final accountCurrency = account.currency;
    if (accountCurrency == baseCurrency) {
      if (mounted) _clearRateChip();
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
    if (requestSerial != _rateRequestSerial ||
        accountUuid != _form.accountUuid) {
      return;
    }

    result.fold((_) => _clearRateChip(), (entity) {
      if (entity == null) {
        _clearRateChip();
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

  void _clearRateChip() {
    setState(() {
      _rateChipLabel = null;
      _rateIsStale = false;
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

  void _selectAccount(String? uuid) {
    setState(() => _form.accountUuid = uuid);
    _fetchRate();
  }

  void _setRecurrence(RecurrenceFrequency? frequency) {
    setState(() {
      _form.isRecurring = frequency != null;
      if (frequency != null) _form.recurrenceFrequency = frequency;
    });
  }

  void _selectType(TransactionType type) {
    setState(() {
      _form.type = type;
      _selectInitialCategoryIfNeeded(sl<CategoryCubit>().state.categories);
      _selectInitialToAccountIfNeeded(sl<AccountCubit>().state.accounts);
    });
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
      child: Builder(
        builder: (providerContext) {
          return ScaffoldMessenger(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: MultiBlocListener(
                listeners: [
                  BlocListener<AccountCubit, AccountState>(
                    listenWhen: (prev, curr) => prev.accounts != curr.accounts,
                    listener: (_, _) => _syncInitialSelections(providerContext),
                  ),
                  BlocListener<CategoryCubit, CategoryState>(
                    listenWhen: (prev, curr) =>
                        prev.categories != curr.categories,
                    listener: (_, _) => _syncInitialSelections(providerContext),
                  ),
                ],
                child: TransactionFormContent(
                  form: _form,
                  amountString: _amountString,
                  canDelete: _canDelete,
                  rateChipLabel: _rateChipLabel,
                  rateIsStale: _rateIsStale,
                  saveButton: TransactionSaveButton(
                    isEnabled: _form.isValidAmount,
                    isEditing: isEditing,
                    isRecurring: _form.isRecurring,
                    isRecurringDraft: _isRecurringDraft,
                    isSavingEditWithRecurring: _isSavingEditWithRecurring,
                    onPressed: _saveTransaction,
                    onTransactionStateChanged: _onTransactionStateChanged,
                    onRecurringStateChanged: _onRecurringStateChanged,
                  ),
                  onAccountSelected: _selectAccount,
                  onRecurrenceChanged: _setRecurrence,
                  onDelete: () => _showDeleteDialog(providerContext),
                  onTypeChanged: _selectType,
                  onCategorySelected: (uuid) =>
                      setState(() => _form.categoryUuid = uuid),
                  onToAccountSelected: (uuid) =>
                      setState(() => _form.toAccountUuid = uuid),
                  onDateSelected: (date) => setState(() => _form.date = date),
                  onNoteChanged: (note) => setState(() => _form.note = note),
                  onNumpadKey: _onNumpadKey,
                  onBackspace: _onBackspace,
                  onClear: _onClear,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _syncInitialSelectionsFromCubitState() {
    _selectInitialCategoryIfNeeded(sl<CategoryCubit>().state.categories);
    _selectInitialToAccountIfNeeded(sl<AccountCubit>().state.accounts);
  }

  void _syncInitialSelections(BuildContext context) {
    final changed =
        _selectInitialCategoryIfNeeded(
          context.read<CategoryCubit>().state.categories,
        ) ||
        _selectInitialToAccountIfNeeded(
          context.read<AccountCubit>().state.accounts,
        );

    if (changed && mounted) setState(() {});
  }

  bool _selectInitialCategoryIfNeeded(List<CategoryEntity> categories) {
    if (isEditing) return false;
    if (_form.isTransfer || _form.isAdjustment) return false;
    if (_form.categoryUuid != null) return false;

    final filteredCategories = _form.filterCategories(categories);
    if (filteredCategories.isEmpty) return false;

    _form.categoryUuid = filteredCategories.first.uuid;
    return true;
  }

  bool _selectInitialToAccountIfNeeded(List<AccountEntity> accounts) {
    if (isEditing) return false;
    if (!_form.isTransfer) return false;
    if (_form.toAccountUuid != null) return false;

    final availableToAccounts = _form.filterToAccounts(accounts);
    if (availableToAccounts.isEmpty) return false;

    _form.toAccountUuid = availableToAccounts.first.uuid;
    return true;
  }

  void _onTransactionStateChanged(
    BuildContext context,
    TransactionState state,
  ) {
    if (_isDeletingRecurring) {
      _handleRecurringDeletionState(context, state);
      return;
    }

    if (_isSavingEditWithRecurring) {
      _handleEditWithRecurringTransactionState(context, state);
      return;
    }

    if (_form.isRecurring) return;
    _handleSimpleTransactionState(context, state);
  }

  void _onRecurringStateChanged(
    BuildContext context,
    RecurringTransactionState state,
  ) {
    if (_isSavingEditWithRecurring) {
      _handleEditWithRecurringTemplateState(context, state);
      return;
    }

    if (!_form.isRecurring || isEditing) return;
    _handleSimpleRecurringState(context, state);
  }

  void _handleRecurringDeletionState(
    BuildContext context,
    TransactionState state,
  ) {
    if (state.status == CubitStatus.success) {
      _isDeletingRecurring = false;
      Navigator.pop(context, true);
      return;
    }
    if (state.status != CubitStatus.failure) return;
    _isDeletingRecurring = false;
    _showSaveError(context, state.errorMessage ?? context.l10n.failedToSave);
  }

  void _handleEditWithRecurringTransactionState(
    BuildContext context,
    TransactionState state,
  ) {
    if (state.status == CubitStatus.success) {
      _transactionSaveCompleted = true;
      _completeEditWithRecurringIfReady(context);
      return;
    }
    if (state.status != CubitStatus.failure) return;
    _resetEditWithRecurringState();
    _showSaveError(context, state.errorMessage ?? context.l10n.failedToSave);
  }

  void _handleEditWithRecurringTemplateState(
    BuildContext context,
    RecurringTransactionState state,
  ) {
    if (state.status == CubitStatus.success) {
      _recurringSaveCompleted = true;
      _completeEditWithRecurringIfReady(context);
      return;
    }
    if (state.status != CubitStatus.failure) return;
    _resetEditWithRecurringState();
    _showSaveError(context, state.errorMessage ?? context.l10n.failedToSave);
  }

  void _handleSimpleTransactionState(
    BuildContext context,
    TransactionState state,
  ) {
    if (state.status == CubitStatus.success) {
      Navigator.pop(context, true);
      return;
    }
    if (state.status != CubitStatus.failure) return;
    _showSaveError(context, state.errorMessage ?? context.l10n.failedToSave);
  }

  void _handleSimpleRecurringState(
    BuildContext context,
    RecurringTransactionState state,
  ) {
    if (state.status == CubitStatus.success) {
      Navigator.pop(context, true);
      return;
    }
    if (state.status != CubitStatus.failure) return;
    _showSaveError(context, state.errorMessage ?? context.l10n.failedToSave);
  }

  Future<void> _saveTransaction(BuildContext context) async {
    final error = _form.validate();
    if (error != null) {
      _showSaveError(context, error);
      return;
    }

    final account = context.read<AccountCubit>().state.accounts.firstWhere(
      (a) => a.uuid == _form.accountUuid,
    );
    final recurringTemplate = _recurringActions.resolveTemplate(context);
    final transaction = _transactionFromForm(account, recurringTemplate);

    final handledRecurringEdit = await _recurringActions
        .handleRecurringEditIfNeeded(
          context: context,
          isEditing: isEditing,
          updatedTransaction: transaction,
        );
    if (!context.mounted) return;
    if (handledRecurringEdit) {
      return;
    }

    if (_form.isRecurring) {
      _saveRecurringTransaction(context, account);
      if (!isEditing) return;
    }

    if (isEditing) {
      context.read<TransactionCubit>().editTransaction(transaction);
      return;
    }

    context.read<TransactionCubit>().addTransaction(transaction);
  }

  TransactionEntity _transactionFromForm(
    AccountEntity account,
    RecurringTransactionEntity? recurringTemplate,
  ) {
    return TransactionEntity(
      uuid: isEditing ? widget.transaction!.uuid : const Uuid().v4(),
      amount: _signedAmount,
      currency: account.currency,
      type: _form.type,
      categoryUuid: _categoryUuid,
      accountUuid: _form.accountUuid!,
      toAccountUuid: _form.toAccountUuid,
      note: _note,
      date: _form.date,
      createdDate: isEditing ? widget.transaction!.createdDate : DateTime.now(),
      recurringTemplateUuid:
          recurringTemplate?.uuid ?? widget.transaction?.recurringTemplateUuid,
    );
  }

  void _saveRecurringTransaction(BuildContext context, AccountEntity account) {
    final recurring = _recurringTransactionFromForm(account);
    final recurringCubit = context.read<RecurringTransactionCubit>();

    if (isEditing) {
      _startEditWithRecurringSave();
      recurringCubit.addRecurringTransaction(recurring);
      return;
    }

    recurringCubit.addRecurringTransaction(recurring);
  }

  RecurringTransactionEntity _recurringTransactionFromForm(
    AccountEntity account,
  ) {
    return RecurringTransactionEntity(
      uuid: const Uuid().v4(),
      amount: _signedAmount,
      currency: account.currency,
      type: _form.type,
      categoryUuid: _categoryUuid,
      accountUuid: _form.accountUuid!,
      toAccountUuid: _form.toAccountUuid,
      note: _note,
      startDate: _form.date,
      createdDate: DateTime.now(),
      frequency: _form.recurrenceFrequency,
    );
  }

  void _startEditWithRecurringSave() {
    _isSavingEditWithRecurring = true;
    _transactionSaveCompleted = false;
    _recurringSaveCompleted = false;
  }

  String get _categoryUuid =>
      _form.isTransfer || _form.isAdjustment ? '' : (_form.categoryUuid ?? '');

  String? get _note => _form.note.isEmpty ? null : _form.note;

  double get _signedAmount => _form.isAdjustment && _isNegativeAdjustment
      ? -_form.amount
      : _form.amount;

  Future<void> _showDeleteDialog(BuildContext context) async {
    await _recurringActions.confirmDelete(
      context: context,
      isEditing: isEditing,
      onRecurringDeleteStarted: _startRecurringDelete,
    );
  }

  void _startRecurringDelete() {
    _isDeletingRecurring = true;
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
    _topSnackBar.showError(context, message);
  }
}
