import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            type == TransactionType.transfer
                ? TransactionDestinationAccountPicker(
                    selectedAccount: selectedToAccount,
                    accounts: availableToAccounts,
                    onSelected: onToAccountSelected,
                  )
                : TransactionCategoryPicker(
                    selectedCategory: selectedCategory,
                    categories: categories,
                    onCategorySelected: onCategorySelected,
                  ),
            TransactionDatePicker(date: date, onDateSelected: onDateSelected),
          ],
        ),
        const SizedBox(height: 8),
        TransactionNoteField(note: note, onNoteChanged: onNoteChanged),
      ],
    );
  }
}
