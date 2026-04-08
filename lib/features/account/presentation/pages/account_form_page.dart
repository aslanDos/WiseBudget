import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/widgets/color_picker.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/widgets/account_icon_selector.dart';
import 'package:wisebuget/features/account/presentation/widgets/account_save_button.dart';

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
              Text('Icon', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8.0),
              AccountIconSelector(
                iconOptions: _iconOptions,
                selectedIconCode: _selectedIconCode,
                onSelected: (code) => setState(() => _selectedIconCode = code),
              ),
              const SizedBox(height: 24.0),

              Text('Color', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8.0),
              ColorPicker(
                selectedColorValue: _selectedColorValue,
                onColorSelected: (value) =>
                    setState(() => _selectedColorValue = value),
              ),
              const SizedBox(height: 24.0),

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
                  if (value != null) setState(() => _selectedCurrency = value);
                },
              ),
              const SizedBox(height: 16.0),

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

              AccountSaveButton(
                isEditing: widget.isEditing,
                onSave: () => _saveAccount(context),
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
      cubit.editAccount(
        widget.account!.copyWith(
          name: _nameController.text.trim(),
          currency: _selectedCurrency,
          balance: balance,
          iconCode: _selectedIconCode,
          colorValue: _selectedColorValue,
        ),
      );
    } else {
      cubit.addAccount(
        AccountEntity(
          uuid: const Uuid().v4(),
          name: _nameController.text.trim(),
          currency: _selectedCurrency,
          balance: balance,
          iconCode: _selectedIconCode,
          createdDate: DateTime.now(),
          colorValue: _selectedColorValue,
        ),
      );
    }
  }
}
