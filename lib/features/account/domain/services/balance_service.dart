import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

/// Domain service for calculating account balance changes.
///
/// This service contains pure business logic for balance calculations,
/// keeping it separate from state management concerns.
class BalanceService {
  const BalanceService();

  /// Calculates the balance adjustment for a single account from a transaction.
  ///
  /// Returns the amount to add to the account balance.
  /// Negative values decrease the balance, positive values increase it.
  double calculateBalanceChange(
    TransactionEntity transaction,
    String accountUuid, {
    bool reverse = false,
  }) {
    final multiplier = reverse ? -1.0 : 1.0;

    // Check if this account is the source account
    if (transaction.accountUuid == accountUuid) {
      return switch (transaction.type) {
        TransactionType.expense => -transaction.amount * multiplier,
        TransactionType.income => transaction.amount * multiplier,
        TransactionType.transfer => -transaction.amount * multiplier,
        // Adjustment balance is set directly in account_form; no effect here.
        TransactionType.adjustment => 0.0,
      };
    }

    // Check if this account is the destination (for transfers)
    if (transaction.toAccountUuid == accountUuid) {
      return transaction.amount * multiplier;
    }

    // Account not involved in this transaction
    return 0.0;
  }

  /// Calculates all balance changes for a transaction.
  ///
  /// Returns a map of accountUuid -> balance change amount.
  Map<String, double> calculateAllBalanceChanges(
    TransactionEntity transaction, {
    bool reverse = false,
  }) {
    final changes = <String, double>{};
    final multiplier = reverse ? -1.0 : 1.0;

    switch (transaction.type) {
      case TransactionType.expense:
        changes[transaction.accountUuid] = -transaction.amount * multiplier;

      case TransactionType.income:
        changes[transaction.accountUuid] = transaction.amount * multiplier;

      case TransactionType.transfer:
        changes[transaction.accountUuid] = -transaction.amount * multiplier;
        if (transaction.toAccountUuid != null) {
          changes[transaction.toAccountUuid!] = transaction.amount * multiplier;
        }

      case TransactionType.adjustment:
        // Balance is set directly in account_form; no effect here.
        break;
    }

    return changes;
  }

  /// Calculates total balance for an account from a list of transactions.
  ///
  /// Useful for recalculating account balance from transaction history.
  double calculateTotalBalance(
    List<TransactionEntity> transactions,
    String accountUuid,
    double initialBalance,
  ) {
    var balance = initialBalance;

    for (final tx in transactions) {
      balance += calculateBalanceChange(tx, accountUuid);
    }

    return balance;
  }

  /// Calculates balance changes when editing a transaction.
  ///
  /// Returns changes needed to update from old to new transaction state.
  Map<String, double> calculateEditChanges(
    TransactionEntity oldTransaction,
    TransactionEntity newTransaction,
  ) {
    final reverseOld = calculateAllBalanceChanges(
      oldTransaction,
      reverse: true,
    );
    final applyNew = calculateAllBalanceChanges(newTransaction);

    // Merge the changes
    final combined = <String, double>{};

    for (final entry in reverseOld.entries) {
      combined[entry.key] = (combined[entry.key] ?? 0) + entry.value;
    }

    for (final entry in applyNew.entries) {
      combined[entry.key] = (combined[entry.key] ?? 0) + entry.value;
    }

    // Remove zero changes
    combined.removeWhere((_, value) => value == 0);

    return combined;
  }
}
