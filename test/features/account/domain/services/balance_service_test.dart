import 'package:flutter_test/flutter_test.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/features/account/domain/services/balance_service.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

void main() {
  group('BalanceService', () {
    const service = BalanceService();

    TransactionEntity transaction({
      required String uuid,
      required TransactionType type,
      required double amount,
      required String accountUuid,
      String? toAccountUuid,
    }) {
      return TransactionEntity(
        uuid: uuid,
        amount: amount,
        currency: 'USD',
        type: type,
        categoryUuid: 'category-1',
        accountUuid: accountUuid,
        toAccountUuid: toAccountUuid,
        date: DateTime(2026, 4, 24),
        createdDate: DateTime(2026, 4, 24),
      );
    }

    test('calculates transfer edit changes across both accounts', () {
      final oldTransaction = transaction(
        uuid: 'tx-1',
        type: TransactionType.transfer,
        amount: 100,
        accountUuid: 'account-a',
        toAccountUuid: 'account-b',
      );
      final newTransaction = transaction(
        uuid: 'tx-1',
        type: TransactionType.transfer,
        amount: 70,
        accountUuid: 'account-a',
        toAccountUuid: 'account-c',
      );

      final changes = service.calculateEditChanges(
        oldTransaction,
        newTransaction,
      );

      expect(changes['account-a'], 30);
      expect(changes['account-b'], -100);
      expect(changes['account-c'], 70);
    });

    test('calculates total balance from mixed transactions', () {
      final transactions = [
        transaction(
          uuid: 'income',
          type: TransactionType.income,
          amount: 500,
          accountUuid: 'cash',
        ),
        transaction(
          uuid: 'expense',
          type: TransactionType.expense,
          amount: 120,
          accountUuid: 'cash',
        ),
        transaction(
          uuid: 'transfer',
          type: TransactionType.transfer,
          amount: 80,
          accountUuid: 'cash',
          toAccountUuid: 'bank',
        ),
      ];

      expect(service.calculateTotalBalance(transactions, 'cash', 0), 300);
      expect(service.calculateTotalBalance(transactions, 'bank', 0), 80);
    });
  });
}
