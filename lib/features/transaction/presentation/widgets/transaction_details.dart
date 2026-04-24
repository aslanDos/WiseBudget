import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/layout/app_breakpoints.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_category_picker.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_date_picker.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_destination_account_picker.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_note_field.dart';

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
    final leadingField = switch (type) {
      TransactionType.transfer => TransactionDestinationAccountPicker(
        selectedAccount: selectedToAccount,
        accounts: availableToAccounts,
        onSelected: onToAccountSelected,
      ),
      TransactionType.adjustment => null,
      _ => TransactionCategoryPicker(
        selectedCategory: selectedCategory,
        categories: categories,
        onCategorySelected: onCategorySelected,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final datePicker = TransactionDatePicker(
              date: date,
              onDateSelected: onDateSelected,
            );

            if (leadingField == null) {
              return Align(alignment: Alignment.centerLeft, child: datePicker);
            }

            if (constraints.maxWidth < AppBreakpoints.pickerStack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [leadingField, const SizedBox(height: 8), datePicker],
              );
            }

            return Row(
              children: [
                Expanded(child: leadingField),
                const SizedBox(width: 8),
                datePicker,
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        TransactionNoteField(note: note, onNoteChanged: onNoteChanged),
      ],
    );
  }
}
