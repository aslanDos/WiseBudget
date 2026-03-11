import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/text_field.dart';
import 'package:wisebuget/core/shared/widgets/numpad.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
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
  late final TextEditingController _noteController;

  late TransactionType _selectedType;
  String _amount = '';
  String? _selectedAccountUuid;
  String? _selectedCategoryUuid;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transaction?.type ?? widget.initialType;
    _amount = widget.transaction?.amount.toString() ?? '';
    _noteController = TextEditingController(
      text: widget.transaction?.note ?? '',
    );
    _selectedAccountUuid = widget.transaction?.accountUuid;
    _selectedCategoryUuid = widget.transaction?.categoryUuid;
    _selectedDate = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onNumpadKeyPressed(String key) {
    setState(() {
      if (key == '.' && _amount.contains('.')) return;
      if (key == '.' && _amount.isEmpty) {
        _amount = '0.';
        return;
      }
      // Limit decimal places to 2
      if (_amount.contains('.')) {
        final decimalPart = _amount.split('.').last;
        if (decimalPart.length >= 2) return;
      }
      _amount += key;
    });
  }

  void _onBackspace() {
    if (_amount.isNotEmpty) {
      setState(() {
        _amount = _amount.substring(0, _amount.length - 1);
      });
    }
  }

  void _onClear() {
    setState(() {
      _amount = '';
    });
  }

  String get _displayAmount {
    if (_amount.isEmpty) return '0';
    return _amount;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<TransactionCubit>()),
        BlocProvider.value(value: sl<AccountCubit>()..loadAccounts()),
        BlocProvider(create: (_) => sl<CategoryCubit>()..loadCategories()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Edit Transaction' : 'New Transaction',
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Transaction type selector
                    TypeToggle<TransactionType>(
                      items: TransactionType.values
                          .map(
                            (type) => TypeToggleItem(
                              value: type,
                              label: type.label,
                              icon: type.icon,
                            ),
                          )
                          .toList(),
                      selected: _selectedType,
                      onChanged: (type) => setState(() => _selectedType = type),
                      selectedBackgroundColor: (type) =>
                          type.actionBackgroundColor(context),
                      selectedForegroundColor: (type) =>
                          type.actionColor(context),
                    ),
                    const SizedBox(height: 24.0),

                    // Amount display
                    _AmountDisplay(amount: _displayAmount, type: _selectedType),
                    const SizedBox(height: 24.0),

                    // Numpad
                    Numpad(
                      onKeyPressed: _onNumpadKeyPressed,
                      onBackspace: _onBackspace,
                      onClear: _onClear,
                    ),
                    const SizedBox(height: 24.0),

                    // Account selector
                    _AccountSelector(
                      selectedAccountUuid: _selectedAccountUuid,
                      onChanged: (value) =>
                          setState(() => _selectedAccountUuid = value),
                    ),
                    const SizedBox(height: 16.0),

                    // Category selector
                    if (_selectedType != TransactionType.transfer) ...[
                      _CategorySelector(
                        selectedType: _selectedType,
                        selectedCategoryUuid: _selectedCategoryUuid,
                        onChanged: (value) =>
                            setState(() => _selectedCategoryUuid = value),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    // Date picker
                    _DatePicker(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                    const Divider(),

                    // Note field
                    AppTextField(
                      controller: _noteController,
                      labelText: 'Note (optional)',
                      prefixIcon: const Icon(Icons.notes),
                      maxLines: 2,
                      maxLength: TransactionEntity.maxNoteLength,
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),

              // Save button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocConsumer<TransactionCubit, TransactionState>(
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
                    return SizedBox(
                      width: double.infinity,
                      child: Button(
                        label: widget.isEditing
                            ? 'Save Changes'
                            : 'Add ${_selectedType.label}',
                        icon: Icon(_selectedType.icon),
                        backgroundColor: _selectedType.actionBackgroundColor(
                          context,
                        ),
                        foregroundColor: _selectedType.actionColor(context),
                        isLoading: isLoading,
                        onPressed: () => _saveTransaction(context),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction(BuildContext context) {
    if (_amount.isEmpty || double.tryParse(_amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final amount = double.parse(_amount);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0')),
      );
      return;
    }

    if (_selectedAccountUuid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }

    if (_selectedType != TransactionType.transfer &&
        _selectedCategoryUuid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final cubit = context.read<TransactionCubit>();

    // Get account currency
    final accountCubit = context.read<AccountCubit>();
    final account = accountCubit.state.accounts.firstWhere(
      (a) => a.uuid == _selectedAccountUuid,
    );

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

class _AmountDisplay extends StatelessWidget {
  final String amount;
  final TransactionType type;

  const _AmountDisplay({required this.amount, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: type.actionBackgroundColor(context).withAlpha(0x1A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Icon(
            type.icon,
            color: type.actionBackgroundColor(context),
            size: 32.0,
          ),
          const SizedBox(height: 8.0),
          Text(
            amount,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: type.actionBackgroundColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSelector extends StatelessWidget {
  final String? selectedAccountUuid;
  final ValueChanged<String?> onChanged;

  const _AccountSelector({
    required this.selectedAccountUuid,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AccountCubit, AccountState>(
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
        final effectiveSelectedUuid =
            selectedAccountUuid ?? accounts.first.uuid;
        if (selectedAccountUuid == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onChanged(accounts.first.uuid);
          });
        }

        return DropdownButtonFormField<String>(
          initialValue: effectiveSelectedUuid,
          decoration: const InputDecoration(
            labelText: 'Account',
            prefixIcon: Icon(AppIcons.wallet),
            border: OutlineInputBorder(),
          ),
          items: accounts
              .map((a) => DropdownMenuItem(value: a.uuid, child: Text(a.name)))
              .toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'Please select an account';
            }
            return null;
          },
        );
      },
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final TransactionType selectedType;
  final String? selectedCategoryUuid;
  final ValueChanged<String?> onChanged;

  const _CategorySelector({
    required this.selectedType,
    required this.selectedCategoryUuid,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state.status == CategoryStatus.loading) {
          return const LinearProgressIndicator();
        }

        // Filter categories by transaction type and visibility
        final categoryType = selectedType == TransactionType.income
            ? TransactionType.income
            : TransactionType.expense;
        final categories = state.categories
            .where((c) => c.type == categoryType && c.visible)
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
        String? effectiveSelectedUuid = selectedCategoryUuid;
        if (selectedCategoryUuid == null ||
            !categories.any((c) => c.uuid == selectedCategoryUuid)) {
          effectiveSelectedUuid = categories.first.uuid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onChanged(categories.first.uuid);
          });
        }

        return DropdownButtonFormField<String>(
          initialValue: effectiveSelectedUuid,
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(AppIcons.grid),
            border: OutlineInputBorder(),
          ),
          items: categories
              .map(
                (c) {
                  final categoryColor = AppPalette.fromValue(
                    c.colorValue,
                    defaultColor: colorScheme.primary,
                  );
                  return DropdownMenuItem(
                    value: c.uuid,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: categoryColor.withAlpha(0x33),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Icon(
                            AppIcons.fromCode(c.iconCode),
                            size: 20,
                            color: categoryColor,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(c.name),
                      ],
                    ),
                  );
                },
              )
              .toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
        );
      },
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePicker({required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(AppIcons.calendar),
      title: const Text('Date'),
      subtitle: Text(_formatDate(selectedDate)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _selectDate(context),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onDateSelected(picked);
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
}
