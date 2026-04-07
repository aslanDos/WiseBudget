import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/shared/widgets/picker_list_tile.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class TransactionDetails extends StatelessWidget {
  final TransactionType type;
  final DateTime date;
  final String note;

  // Category
  final CategoryEntity? selectedCategory;
  final List<CategoryEntity> categories;
  final ValueChanged<String> onCategorySelected;

  // Transfer destination
  final AccountEntity? selectedToAccount;
  final List<AccountEntity> availableToAccounts;
  final ValueChanged<String> onToAccountSelected;

  // Common callbacks
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onNoteChanged;

  const TransactionDetails({
    super.key,
    required this.type,
    required this.date,
    required this.note,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.selectedToAccount,
    required this.availableToAccounts,
    required this.onToAccountSelected,
    required this.onDateSelected,
    required this.onNoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            type == TransactionType.transfer
                ? _DestinationAccountPicker(
                    selectedAccount: selectedToAccount,
                    accounts: availableToAccounts,
                    onSelected: onToAccountSelected,
                  )
                : _CategoryPicker(
                    selectedCategory: selectedCategory,
                    categories: categories,
                    onCategorySelected: onCategorySelected,
                  ),
            _DatePicker(date: date, onDateSelected: onDateSelected),
          ],
        ),
        const SizedBox(height: 8),
        _NoteField(note: note, onNoteChanged: onNoteChanged),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePicker({required this.date, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return PickerField(
      icon: AppIcons.calendar,
      iconBackgroundColor: context.c.surfaceContainer,
      label: DateFormatter.format(date),
      shrink: true,
      onTap: () => _showDatePicker(context),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) onDateSelected(picked);
  }
}

class _CategoryPicker extends StatelessWidget {
  final CategoryEntity? selectedCategory;
  final List<CategoryEntity> categories;
  final ValueChanged<String> onCategorySelected;

  const _CategoryPicker({
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = selectedCategory != null
        ? AppPalette.fromValue(
            selectedCategory!.colorValue,
            defaultColor: context.c.primary,
          )
        : context.c.onSecondary;

    return PickerField(
      icon: selectedCategory != null
          ? AppIcons.fromCode(selectedCategory!.iconCode)
          : AppIcons.grid,
      iconColor: categoryColor,
      label: selectedCategory?.name ?? 'No category',
      shrink: true,
      onTap: () => _showCategoryPicker(context),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    if (categories.isEmpty) return;

    showModal(
      context: context,
      builder: (context) => ModalSheet.scrollable(
        title: const Text('Select Category'),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.uuid == selectedCategory?.uuid;
            final color = AppPalette.fromValue(
              category.colorValue,
              defaultColor: Theme.of(context).colorScheme.primary,
            );

            return PickerListTile(
              icon: AppIcons.fromCode(category.iconCode),
              iconColor: color,
              iconBackgroundColor: color.withAlpha(0x33),
              title: category.name,
              isSelected: isSelected,
              onTap: () {
                onCategorySelected(category.uuid);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  final String note;
  final ValueChanged<String> onNoteChanged;

  const _NoteField({required this.note, required this.onNoteChanged});

  @override
  Widget build(BuildContext context) {
    return PickerField(
      icon: AppIcons.feather,
      iconBackgroundColor: context.c.surfaceContainer,
      label: note.isEmpty ? 'Note' : note,
      shrink: false,
      onTap: () => _showNoteInput(context),
    );
  }

  Future<void> _showNoteInput(BuildContext context) async {
    final result = await showModalInput(
      context: context,
      initialValue: note,
      hintText: 'Add a note...',
      maxLength: 200,
    );
    if (result != null) onNoteChanged(result);
  }
}

class _DestinationAccountPicker extends StatelessWidget {
  final AccountEntity? selectedAccount;
  final List<AccountEntity> accounts;
  final ValueChanged<String> onSelected;

  const _DestinationAccountPicker({
    required this.selectedAccount,
    required this.accounts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = selectedAccount != null
        ? AppPalette.fromValue(
            selectedAccount!.colorValue,
            defaultColor: context.c.primary,
          )
        : context.c.primary;

    return PickerField(
      icon: selectedAccount != null
          ? AppIcons.fromCode(selectedAccount!.iconCode)
          : AppIcons.circle,
      iconColor: iconColor,
      label: selectedAccount?.name ?? 'Select destination',
      shrink: true,
      showChevron: false,
      onTap: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    if (accounts.isEmpty) return;

    showModal(
      context: context,
      builder: (context) => ModalSheet.scrollable(
        title: const Text('Select Destination Account'),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            final isSelected = account.uuid == selectedAccount?.uuid;
            final color = AppPalette.fromValue(
              account.colorValue,
              defaultColor: Theme.of(context).colorScheme.primary,
            );

            return PickerListTile(
              icon: AppIcons.fromCode(account.iconCode),
              iconColor: color,
              iconBackgroundColor: color.withAlpha(0x33),
              title: account.name,
              subtitle: account.money.formatted,
              isSelected: isSelected,
              onTap: () {
                onSelected(account.uuid);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
