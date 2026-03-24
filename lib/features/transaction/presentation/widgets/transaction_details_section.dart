import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class TransactionDetailsSection extends StatelessWidget {
  final TransactionType type;
  final DateTime date;
  final String note;

  // Category (for income/expense)
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

  const TransactionDetailsSection({
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
        // Date
        _LabeledField(
          label: 'Date',
          child: _DatePicker(
            date: date,
            onDateSelected: onDateSelected,
          ),
        ),
        const SizedBox(height: 16),
        // Category or To Account
        if (type == TransactionType.transfer)
          _LabeledField(
            label: 'To account',
            child: _ToAccountPicker(
              selectedAccount: selectedToAccount,
              accounts: availableToAccounts,
              onSelected: onToAccountSelected,
            ),
          )
        else
          _LabeledField(
            label: 'Category',
            child: _CategoryPicker(
              selectedCategory: selectedCategory,
              categories: categories,
              onSelected: onCategorySelected,
            ),
          ),
        const SizedBox(height: 16),
        // Note
        _LabeledField(
          label: 'Note',
          child: _NoteField(
            note: note,
            onNoteChanged: onNoteChanged,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePicker({
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PickerField(
      icon: AppIcons.calendar,
      iconColor: colorScheme.tertiary,
      iconBackgroundColor: context.c.secondary.withValues(alpha: 0.3),
      label: _formatDate(date),
      showChevron: false,
      onTap: () => _showDatePicker(context),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Today';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

class _NoteField extends StatelessWidget {
  final String note;
  final ValueChanged<String> onNoteChanged;

  const _NoteField({
    required this.note,
    required this.onNoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PickerField(
      icon: Icons.notes_outlined,
      iconColor: colorScheme.secondary,
      iconBackgroundColor: context.c.secondary.withValues(alpha: 0.3),
      label: note.isEmpty ? 'Add note' : note,
      showChevron: false,
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

class _CategoryPicker extends StatelessWidget {
  final CategoryEntity? selectedCategory;
  final List<CategoryEntity> categories;
  final ValueChanged<String> onSelected;

  const _CategoryPicker({
    required this.selectedCategory,
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selectedCategory != null
        ? AppPalette.fromValue(
            selectedCategory!.colorValue,
            defaultColor: colorScheme.primary,
          )
        : colorScheme.primary;

    return PickerField(
      icon: selectedCategory != null
          ? AppIcons.fromCode(selectedCategory!.iconCode)
          : AppIcons.grid,
      iconColor: color,
      iconBackgroundColor: context.c.secondary.withValues(alpha: 0.3),
      label: selectedCategory?.name ?? 'Select category',
      showChevron: false,
      onTap: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    if (categories.isEmpty) return;
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
            final isSelected = category.uuid == selectedCategory?.uuid;
            final color = AppPalette.fromValue(
              category.colorValue,
              defaultColor: colorScheme.primary,
            );

            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(0x33),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(AppIcons.fromCode(category.iconCode), color: color),
              ),
              title: Text(category.name),
              trailing:
                  isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
              onTap: () {
                onSelected(category.uuid);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ToAccountPicker extends StatelessWidget {
  final AccountEntity? selectedAccount;
  final List<AccountEntity> accounts;
  final ValueChanged<String> onSelected;

  const _ToAccountPicker({
    required this.selectedAccount,
    required this.accounts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PickerField(
      icon: AppIcons.wallet,
      iconColor: colorScheme.tertiary,
      iconBackgroundColor: context.c.secondary.withValues(alpha: 0.3),
      label: selectedAccount?.name ?? 'Select destination',
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
            final colorScheme = Theme.of(context).colorScheme;

            return ListTile(
              leading: Icon(
                AppIcons.wallet,
                color: isSelected ? colorScheme.primary : null,
              ),
              title: Text(account.name),
              subtitle: Text(account.currency),
              trailing:
                  isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
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
