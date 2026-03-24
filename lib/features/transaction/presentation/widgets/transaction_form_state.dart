import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

class TransactionFormData {
  TransactionType type;
  double amount;
  String? accountUuid;
  String? toAccountUuid;
  String? incomeCategoryUuid;
  String? expenseCategoryUuid;
  DateTime date;
  String note;

  TransactionFormData({
    required this.type,
    this.amount = 0,
    this.accountUuid,
    this.toAccountUuid,
    this.incomeCategoryUuid,
    this.expenseCategoryUuid,
    DateTime? date,
    this.note = '',
  }) : date = date ?? DateTime.now();

  factory TransactionFormData.fromTransaction(
    TransactionEntity? tx,
    TransactionType initialType,
  ) {
    if (tx == null) {
      return TransactionFormData(type: initialType);
    }
    return TransactionFormData(
      type: tx.type,
      amount: tx.amount,
      accountUuid: tx.accountUuid,
      toAccountUuid: tx.toAccountUuid,
      incomeCategoryUuid:
          tx.type == TransactionType.income ? tx.categoryUuid : null,
      expenseCategoryUuid:
          tx.type == TransactionType.expense ? tx.categoryUuid : null,
      date: tx.date,
      note: tx.note ?? '',
    );
  }

  String? get categoryUuid =>
      type == TransactionType.income ? incomeCategoryUuid : expenseCategoryUuid;

  set categoryUuid(String? uuid) {
    if (type == TransactionType.income) {
      incomeCategoryUuid = uuid;
    } else {
      expenseCategoryUuid = uuid;
    }
  }

  bool get isTransfer => type == TransactionType.transfer;
  bool get isValidAmount => amount > 0;

  String get displayAmount {
    if (amount == 0) return '0';
    if (amount == amount.truncate()) return amount.truncate().toString();
    return amount
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String? validate() {
    if (amount <= 0) return 'Please enter a valid amount';
    if (accountUuid == null) return 'Please select an account';
    if (isTransfer) {
      if (toAccountUuid == null) return 'Please select a destination account';
      if (accountUuid == toAccountUuid) {
        return 'Source and destination accounts must be different';
      }
    } else if (categoryUuid == null) {
      return 'Please select a category';
    }
    return null;
  }

  List<CategoryEntity> getFilteredCategories(CategoryState state) {
    final filterType = type == TransactionType.income
        ? TransactionType.income
        : TransactionType.expense;
    return state.categories
        .where((c) => c.type == filterType && c.visible)
        .toList();
  }

  CategoryEntity? getSelectedCategory(CategoryState state) {
    return getFilteredCategories(state)
        .where((c) => c.uuid == categoryUuid)
        .firstOrNull;
  }

  List<AccountEntity> getAvailableToAccounts(AccountState state) {
    return state.accounts.where((a) => a.uuid != accountUuid).toList();
  }

  AccountEntity? getSelectedToAccount(AccountState state) {
    return getAvailableToAccounts(state)
        .where((a) => a.uuid == toAccountUuid)
        .firstOrNull;
  }
}
