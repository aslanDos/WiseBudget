import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';

class TransactionFormPage extends StatefulWidget {
  final TransactionType initialType;
  final TransactionEntity? transaction;

  const TransactionFormPage({
    super.key,
    required this.initialType,
    this.transaction,
  });

  bool get isEditing => transaction != null;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _selectedType;
  String? _selectedAccountUuid;
  String? _selectedCategoryUuid;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transaction?.type ?? widget.initialType;
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(
      text: widget.transaction?.note ?? '',
    );
    _selectedAccountUuid = widget.transaction?.accountUuid;
    _selectedCategoryUuid = widget.transaction?.categoryUuid;
    _selectedDate = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<TransactionCubit>()),
        BlocProvider.value(value: sl<AccountCubit>()..loadAccounts()),
        BlocProvider(create: (_) => sl<CategoryCubit>()..loadCategories()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Transaction' : 'New Transaction'),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Transaction type selector
              _TransactionTypeSelector(
                selectedType: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 24.0),

              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(
                    _selectedType.icon,
                    color: _selectedType.actionBackgroundColor(context),
                  ),
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: theme.textTheme.headlineSmall,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Account selector
              BlocBuilder<AccountCubit, AccountState>(
                builder: (context, state) {
                  if (state.status == AccountStatus.loading) {
                    return const LinearProgressIndicator();
                  }

                  final accounts = state.accounts;
                  if (accounts.isEmpty) {
                    return Card(
                      child: ListTile(
                        leading: Icon(AppIcons.wallet, color: colorScheme.error),
                        title: const Text('No accounts available'),
                        subtitle: const Text('Please create an account first'),
                      ),
                    );
                  }

                  // Auto-select first account if none selected
                  _selectedAccountUuid ??= accounts.first.uuid;

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountUuid,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      prefixIcon: Icon(AppIcons.wallet),
                      border: OutlineInputBorder(),
                    ),
                    items: accounts
                        .map((a) => DropdownMenuItem(
                              value: a.uuid,
                              child: Text(a.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedAccountUuid = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an account';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Category selector
              if (_selectedType != TransactionType.transfer)
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    if (state.status == CategoryStatus.loading) {
                      return const LinearProgressIndicator();
                    }

                    // Filter categories by transaction type
                    final categoryType = _selectedType == TransactionType.income
                        ? TransactionType.income
                        : TransactionType.expense;
                    final categories = state.categories
                        .where((c) => c.type == categoryType)
                        .toList();

                    if (categories.isEmpty) {
                      return Card(
                        child: ListTile(
                          leading: Icon(AppIcons.grid, color: colorScheme.outline),
                          title: Text('No ${categoryType.value} categories'),
                          subtitle: const Text('Create categories in Tools'),
                        ),
                      );
                    }

                    // Auto-select first category if none selected or type changed
                    if (_selectedCategoryUuid == null ||
                        !categories.any((c) => c.uuid == _selectedCategoryUuid)) {
                      _selectedCategoryUuid = categories.first.uuid;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryUuid,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(AppIcons.grid),
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c.uuid,
                                child: Row(
                                  children: [
                                    Icon(AppIcons.fromCode(c.iconCode), size: 20),
                                    const SizedBox(width: 8.0),
                                    Text(c.name),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoryUuid = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    );
                  },
                ),
              if (_selectedType != TransactionType.transfer)
                const SizedBox(height: 16.0),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(AppIcons.calendar),
                title: const Text('Date'),
                subtitle: Text(_formatDate(_selectedDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectDate(context),
              ),
              const Divider(),

              // Note field
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                maxLength: TransactionEntity.maxNoteLength,
              ),
              const SizedBox(height: 24.0),

              // Save button
              BlocConsumer<TransactionCubit, TransactionState>(
                listener: (context, state) {
                  if (state.status == TransactionStatus.success) {
                    context.pop(true);
                  } else if (state.status == TransactionStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage ?? 'Failed to save'),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state.status == TransactionStatus.loading;
                  return FilledButton.icon(
                    onPressed: isLoading ? null : () => _saveTransaction(context),
                    icon: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_selectedType.icon),
                    label: Text(
                      widget.isEditing ? 'Save Changes' : 'Add ${_selectedType.label}',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _selectedType.actionBackgroundColor(context),
                      foregroundColor: _selectedType.actionColor(context),
                      padding: const EdgeInsets.all(16.0),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveTransaction(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAccountUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    if (_selectedType != TransactionType.transfer &&
        _selectedCategoryUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final cubit = context.read<TransactionCubit>();
    final amount = double.parse(_amountController.text);

    // Get account currency
    final accountCubit = context.read<AccountCubit>();
    final account = accountCubit.state.accounts
        .firstWhere((a) => a.uuid == _selectedAccountUuid);

    if (widget.isEditing) {
      final updated = widget.transaction!.copyWith(
        amount: amount,
        currency: account.currency,
        type: _selectedType,
        categoryUuid: _selectedCategoryUuid ?? '',
        accountUuid: _selectedAccountUuid,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        date: _selectedDate,
      );
      cubit.editTransaction(updated);
    } else {
      final newTransaction = TransactionEntity(
        uuid: const Uuid().v4(),
        amount: amount,
        currency: account.currency,
        type: _selectedType,
        categoryUuid: _selectedCategoryUuid ?? '',
        accountUuid: _selectedAccountUuid!,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        date: _selectedDate,
        createdDate: DateTime.now(),
      );
      cubit.addTransaction(newTransaction);
    }
  }
}

class _TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  const _TransactionTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      segments: TransactionType.values
          .map(
            (type) => ButtonSegment<TransactionType>(
              value: type,
              label: Text(type.label),
              icon: Icon(type.icon),
            ),
          )
          .toList(),
      selected: {selectedType},
      onSelectionChanged: (set) => onChanged(set.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return selectedType.actionBackgroundColor(context);
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return selectedType.actionColor(context);
          }
          return null;
        }),
      ),
    );
  }
}
