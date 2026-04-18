import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/utils/amount_formatter.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

/// Form data class for transaction creation/editing.
/// Handles form state, validation, and entity filtering.
class TransactionFormEntity {
  TransactionType type;
  double amount;
  String? accountUuid;
  String? toAccountUuid;
  String? incomeCategoryUuid;
  String? expenseCategoryUuid;
  DateTime date;
  String note;

  TransactionFormEntity({
    required this.type,
    this.amount = 0,
    this.accountUuid,
    this.toAccountUuid,
    this.incomeCategoryUuid,
    this.expenseCategoryUuid,
    DateTime? date,
    this.note = '',
  }) : date = date ?? DateTime.now();

  /// Creates form data from an existing transaction (for editing).
  factory TransactionFormEntity.fromTransaction(
    TransactionEntity? tx,
    TransactionType initialType, {
    String? initialAccountUuid,
    DateTime? initialDate,
  }) {
    if (tx == null) {
      return TransactionFormEntity(
        type: initialType,
        accountUuid: initialAccountUuid,
        date: initialDate,
      );
    }

    return TransactionFormEntity(
      type: tx.type,
      amount: tx.amount,
      accountUuid: tx.accountUuid,
      toAccountUuid: tx.toAccountUuid,
      incomeCategoryUuid: tx.isIncome ? tx.categoryUuid : null,
      expenseCategoryUuid: tx.isExpense ? tx.categoryUuid : null,
      date: tx.date,
      note: tx.note ?? '',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Category Handling
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the appropriate category UUID based on transaction type.
  String? get categoryUuid => isAdjustment
      ? null
      : type == TransactionType.income
          ? incomeCategoryUuid
          : expenseCategoryUuid;

  set categoryUuid(String? uuid) {
    if (type == TransactionType.income) {
      incomeCategoryUuid = uuid;
    } else {
      expenseCategoryUuid = uuid;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  bool get isTransfer => type == TransactionType.transfer;
  bool get isAdjustment => type == TransactionType.adjustment;
  bool get isValidAmount => isAdjustment ? amount != 0 : amount > 0;

  /// Formats amount for display using shared formatter.
  String get displayAmount => AmountFormatter.format(amount);

  // ─────────────────────────────────────────────────────────────────────────
  // Validation
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns error message if validation fails, null if valid.
  String? validate() {
    if (!isValidAmount) return 'Please enter a valid amount';
    if (accountUuid == null) return 'Please select an account';

    if (isTransfer) {
      if (toAccountUuid == null) return 'Please select a destination account';
      if (accountUuid == toAccountUuid) {
        return 'Source and destination accounts must be different';
      }
    } else if (!isAdjustment && categoryUuid == null) {
      return 'Please select a category';
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Entity Filtering
  // ─────────────────────────────────────────────────────────────────────────

  /// Filters categories based on transaction type.
  List<CategoryEntity> filterCategories(List<CategoryEntity> categories) {
    final filterType = type == TransactionType.income
        ? TransactionType.income
        : TransactionType.expense;

    return categories.where((c) => c.type == filterType && c.visible).toList();
  }

  /// Finds selected category from filtered list.
  CategoryEntity? findSelectedCategory(List<CategoryEntity> categories) {
    return filterCategories(
      categories,
    ).where((c) => c.uuid == categoryUuid).firstOrNull;
  }

  /// Returns accounts available as transfer destination.
  List<AccountEntity> filterToAccounts(List<AccountEntity> accounts) {
    return accounts.where((a) => a.uuid != accountUuid).toList();
  }

  /// Finds selected destination account.
  AccountEntity? findSelectedToAccount(List<AccountEntity> accounts) {
    return filterToAccounts(
      accounts,
    ).where((a) => a.uuid == toAccountUuid).firstOrNull;
  }
}
