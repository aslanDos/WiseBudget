import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class TransactionPickers extends StatelessWidget {
  final TransactionType selectedType;
  final CategoryEntity? selectedCategory;
  final String categoryName;
  final DateTime selectedDate;
  final String note;
  final List<CategoryEntity> categories;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onNoteChanged;

  // Transfer-specific
  final AccountEntity? selectedToAccount;
  final String toAccountName;
  final List<AccountEntity> availableToAccounts;
  final ValueChanged<String>? onToAccountSelected;

  const TransactionPickers({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
    required this.categoryName,
    required this.selectedDate,
    required this.note,
    required this.categories,
    required this.onCategorySelected,
    required this.onDateSelected,
    required this.onNoteChanged,
    // Transfer-specific
    this.selectedToAccount,
    this.toAccountName = 'Select destination',
    this.availableToAccounts = const [],
    this.onToAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isTransfer = selectedType == TransactionType.transfer;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNoteDateRow(context),
        const SizedBox(height: 12.0),
        if (isTransfer)
          _buildToAccountPicker(context)
        else
          _buildCategoryPicker(context),
      ],
    );
  }

  Widget _buildNoteDateRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildNoteField(context)),
        const SizedBox(width: 12.0),
        Expanded(child: _buildDatePicker(context)),
      ],
    );
  }

  Widget _buildCategoryPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = selectedCategory != null
        ? AppPalette.fromValue(
            selectedCategory!.colorValue,
            defaultColor: colorScheme.primary,
          )
        : colorScheme.primary;

    return PickerField(
      icon: selectedCategory != null
          ? AppIcons.fromCode(selectedCategory!.iconCode)
          : AppIcons.grid,
      iconColor: categoryColor,
      iconBackgroundColor: categoryColor.withAlpha(0x1A),
      label: categoryName,
      showChevron: false,
      onTap: () => _showCategoryPicker(context),
    );
  }

  Widget _buildToAccountPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PickerField(
      icon: AppIcons.wallet,
      iconColor: colorScheme.tertiary,
      iconBackgroundColor: colorScheme.tertiary.withAlpha(0x1A),
      label: toAccountName,
      showChevron: false,
      onTap: () => _showToAccountPicker(context),
    );
  }

  void _showToAccountPicker(BuildContext context) {
    if (availableToAccounts.isEmpty || onToAccountSelected == null) return;

    showAccountPicker(
      context: context,
      accounts: availableToAccounts,
      selectedAccountUuid: selectedToAccount?.uuid,
      onSelected: onToAccountSelected!,
      title: 'Select Destination Account',
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PickerField(
      icon: AppIcons.calendar,
      iconColor: colorScheme.tertiary,
      iconBackgroundColor: context.c.secondary.withValues(alpha: 0.3),
      label: _formatDate(selectedDate),
      showChevron: false,
      onTap: () => _showDatePicker(context),
    );
  }

  Widget _buildNoteField(BuildContext context) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Today';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) onDateSelected(picked);
  }

  void _showCategoryPicker(BuildContext context) {
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
                onCategorySelected(category.uuid);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
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

// Account picker helper
void showAccountPicker({
  required BuildContext context,
  required List<AccountEntity> accounts,
  required String? selectedAccountUuid,
  required ValueChanged<String> onSelected,
  String title = 'Select Account',
}) {
  if (accounts.isEmpty) return;

  showModal(
    context: context,
    builder: (context) => ModalSheet.scrollable(
      title: Text(title),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          final isSelected = account.uuid == selectedAccountUuid;
          final colorScheme = Theme.of(context).colorScheme;

          return ListTile(
            leading: Icon(
              AppIcons.wallet,
              color: isSelected ? colorScheme.primary : null,
            ),
            title: Text(account.name),
            subtitle: Text(account.currency),
            trailing: isSelected
                ? Icon(Icons.check, color: colorScheme.primary)
                : null,
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
