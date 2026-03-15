import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/color_picker.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';

class AccountFormPage extends StatefulWidget {
  final AccountEntity? account;

  const AccountFormPage({super.key, this.account});

  bool get isEditing => account != null;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late String _selectedCurrency;
  late String _selectedIconCode;
  late int _selectedColorValue;

  static const _currencies = ['KZT', 'USD', 'EUR', 'RUB'];
  static const _iconOptions = [
    'wallet',
    'briefCase',
    'receipt',
    'gift',
    'car',
    'shoppingBag',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.account?.balance.toString() ?? '0',
    );
    _selectedCurrency = widget.account?.currency ?? 'KZT';
    _selectedIconCode = widget.account?.iconCode ?? 'wallet';
    _selectedColorValue =
        widget.account?.colorValue ?? AppPalette.defaultAccountColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: sl<AccountCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Account' : 'New Account'),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Icon selector
              Text('Icon', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _iconOptions.map((iconCode) {
                  final isSelected = iconCode == _selectedIconCode;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconCode = iconCode),
                    child: Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12.0),
                        border: isSelected
                            ? Border.all(color: colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Icon(
                        AppIcons.fromCode(iconCode),
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24.0),

              // Color selector
              Text('Color', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8.0),
              ColorPicker(
                selectedColorValue: _selectedColorValue,
                onColorSelected: (colorValue) =>
                    setState(() => _selectedColorValue = colorValue),
              ),
              const SizedBox(height: 24.0),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  hintText: 'e.g., Cash, Savings, Credit Card',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter account name';
                  }
                  if (value.length > AccountEntity.maxNameLength) {
                    return 'Name is too long (max ${AccountEntity.maxNameLength} chars)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Currency selector
              DropdownButtonFormField<String>(
                initialValue: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                items: _currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCurrency = value);
                  }
                },
              ),
              const SizedBox(height: 16.0),

              // Balance field
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Initial Balance',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter balance';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),

              // Save button
              BlocConsumer<AccountCubit, AccountState>(
                listenWhen: (previous, current) =>
                    previous.status == AccountStatus.loading &&
                    current.status != AccountStatus.loading,
                listener: (context, state) {
                  if (state.status == AccountStatus.success) {
                    context.pop(true);
                  } else if (state.status == AccountStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage ?? 'Failed to save'),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state.status == AccountStatus.loading;
                  return FilledButton(
                    onPressed: isLoading ? null : () => _saveAccount(context),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isEditing ? 'Save Changes' : 'Create Account'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAccount(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AccountCubit>();
    final balance = double.parse(_balanceController.text);

    if (widget.isEditing) {
      final updated = widget.account!.copyWith(
        name: _nameController.text.trim(),
        currency: _selectedCurrency,
        balance: balance,
        iconCode: _selectedIconCode,
        colorValue: _selectedColorValue,
      );
      cubit.editAccount(updated);
    } else {
      final newAccount = AccountEntity(
        uuid: const Uuid().v4(),
        name: _nameController.text.trim(),
        currency: _selectedCurrency,
        balance: balance,
        iconCode: _selectedIconCode,
        createdDate: DateTime.now(),
        colorValue: _selectedColorValue,
      );
      cubit.addAccount(newAccount);
    }
  }
}
