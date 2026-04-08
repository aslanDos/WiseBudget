import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/core/shared/widgets/circle_icon_button.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/shared/widgets/picker_list_tile.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/account/presentation/widgets/account_name_field.dart';
import 'package:wisebuget/features/account/presentation/widgets/account_sheet_header.dart';
import 'package:wisebuget/core/shared/widgets/color_grid.dart';
import 'package:wisebuget/core/shared/widgets/color_picker_modal.dart';
import 'package:wisebuget/core/shared/widgets/form_section.dart';
import 'package:wisebuget/core/shared/widgets/icon_grid.dart';
import 'package:wisebuget/core/shared/widgets/icon_picker_modal.dart';

const kAccountIconOptions = [
  'wallet',
  'briefCase',
  'building',
  'home',
  'shoppingBag',
  'car',
  'plane',
  'globe',
  'receipt',
  'gift',
  'star',
  'laptop',
];

const _currencies = ['KZT', 'USD', 'EUR', 'RUB'];

Future<bool?> showAccountFormModal({
  required BuildContext context,
  AccountEntity? account,
}) {
  return showCupertinoModalBottomSheet<bool>(
    context: context,
    expand: false,
    barrierColor: Colors.black54,
    builder: (context) => AccountForm(account: account),
  );
}

class AccountForm extends StatefulWidget {
  final AccountEntity? account;

  const AccountForm({super.key, this.account});

  bool get isEditing => account != null;

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  late String _name;
  late String _selectedIconCode;
  late int _selectedColorValue;
  late String _selectedCurrency;
  late String _balance;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _name = widget.account?.name ?? '';
    _selectedIconCode =
        widget.account?.iconCode ??
        kAccountIconOptions[rng.nextInt(kAccountIconOptions.length)];
    _selectedColorValue =
        widget.account?.colorValue ??
        AppPalette.colors[rng.nextInt(AppPalette.colors.length)];
    _selectedCurrency = widget.account?.currency ?? 'KZT';
    _balance = widget.account != null
        ? widget.account!.balance.toString()
        : '0';
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(_selectedColorValue);

    return BlocProvider.value(
      value: sl<AccountCubit>(),
      child: BlocConsumer<AccountCubit, AccountState>(
        listenWhen: (previous, current) =>
            previous.status == CubitStatus.loading &&
            current.status != CubitStatus.loading,
        listener: (context, state) {
          if (state.status == CubitStatus.success) {
            Navigator.pop(context, true);
          } else if (state.status == CubitStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed to save')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == CubitStatus.loading;

          return Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AccountSheetHeader(
                  title: widget.isEditing
                      ? widget.account!.name
                      : 'New account',
                  trailing: widget.isEditing
                      ? CircleIconButton(
                          icon: AppIcons.trash,
                          onTap: () => _confirmDelete(context),
                          iconColor: Theme.of(context).colorScheme.error,
                        )
                      : const SizedBox(width: 48),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16.0),
                        Center(
                          child: ColoredIconBox(
                            icon: AppIcons.fromCode(_selectedIconCode),
                            color: selectedColor,
                            size: 56.0,
                            padding: 20.0,
                            borderRadius: 24.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        AccountNameField(
                          name: _name,
                          onNameChanged: (name) => setState(() => _name = name),
                        ),
                        const SizedBox(height: 12.0),
                        PickerFieldGroup(
                          backgroundColor: context.c.surfaceContainer,
                          children: [
                            PickerField(
                              icon: Icons.account_balance_rounded,
                              label: 'Balance',
                              value: _balance,
                              shrink: false,
                              onTap: () => _showBalanceInput(context),
                            ),
                            PickerField(
                              icon: Icons.currency_exchange_rounded,
                              label: 'Currency',
                              value: _selectedCurrency,
                              shrink: false,
                              onTap: () => _showCurrencyPicker(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        FormSection(
                          title: 'Color',
                          actionLabel: 'More colors',
                          onAction: () => showColorPickerModal(
                            context: context,
                            selectedColorValue: _selectedColorValue,
                            onColorSelected: (value) =>
                                setState(() => _selectedColorValue = value),
                          ),
                          child: ColorGrid(
                            selectedColorValue: _selectedColorValue,
                            onColorSelected: (value) =>
                                setState(() => _selectedColorValue = value),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        FormSection(
                          title: 'Icon',
                          actionLabel: 'More icons',
                          onAction: () => showIconPickerModal(
                            context: context,
                            selectedIconCode: _selectedIconCode,
                            selectedColor: selectedColor,
                            onIconSelected: (code) =>
                                setState(() => _selectedIconCode = code),
                          ),
                          child: IconGrid(
                            iconOptions: kAccountIconOptions,
                            selectedIconCode: _selectedIconCode,
                            selectedColor: selectedColor,
                            onIconSelected: (code) =>
                                setState(() => _selectedIconCode = code),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Button(
                    label: 'Save',
                    isLoading: isLoading,
                    onPressed: isLoading || _name.trim().isEmpty
                        ? null
                        : () => _saveAccount(context),
                    width: double.infinity,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCurrencyPicker(BuildContext context) async {
    final result = await showModal<String>(
      context: context,
      builder: (context) => ModalSheet.scrollable(
        title: Text('Select Currency'),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _currencies.length,
          itemBuilder: (context, index) {
            final currency = _currencies[index];
            return PickerListTile(
              icon: Icons.currency_exchange_rounded,
              iconColor: Theme.of(context).colorScheme.primary,
              iconBackgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(0x33),
              title: currency,
              isSelected: currency == _selectedCurrency,
              onTap: () => Navigator.pop(context, currency),
            );
          },
        ),
      ),
    );
    if (result != null) setState(() => _selectedCurrency = result);
  }

  Future<void> _showBalanceInput(BuildContext context) async {
    final result = await showModalInput(
      context: context,
      initialValue: _balance == '0' ? '' : _balance,
      hintText: '0.00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    if (result != null) {
      final parsed = double.tryParse(result);
      setState(() => _balance = parsed != null ? result : _balance);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${widget.account!.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AccountCubit>().removeAccount(widget.account!.uuid);
              Navigator.pop(context, true);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAccount(BuildContext context) {
    final name = _name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an account name')),
      );
      return;
    }

    final balance = double.tryParse(_balance) ?? 0.0;
    final cubit = context.read<AccountCubit>();

    if (widget.isEditing) {
      cubit.editAccount(
        widget.account!.copyWith(
          name: name,
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
          name: name,
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
