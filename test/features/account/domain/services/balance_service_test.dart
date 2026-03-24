import 'package:flutter_test/flutter_test.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/features/account/domain/services/balance_service.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

void main() {
  late BalanceService service;

  setUp(() {
    service = const BalanceService();
  });

  TransactionEntity createTransaction({
    required TransactionType type,
    required double amount,
    String accountUuid = 'acc-1',
    String? toAccountUuid,
  }) {
    return TransactionEntity(
      uuid: 'tx-1',
      amount: amount,
      currency: 'USD',
      type: type,
      categoryUuid: 'cat-1',
      accountUuid: accountUuid,
      toAccountUuid: toAccountUuid,
      date: DateTime.now(),
      createdDate: DateTime.now(),
    );
  }

  group('BalanceService', () {
    group('calculateBalanceChange', () {
      test('expense decreases source account balance', () {
        final tx = createTransaction(
          type: TransactionType.expense,
          amount: 100,
        );

        final change = service.calculateBalanceChange(tx, 'acc-1');

        expect(change, -100);
      });

      test('income increases source account balance', () {
        final tx = createTransaction(
          type: TransactionType.income,
          amount: 500,
        );

        final change = service.calculateBalanceChange(tx, 'acc-1');

        expect(change, 500);
      });

      test('transfer decreases source account balance', () {
        final tx = createTransaction(
          type: TransactionType.transfer,
          amount: 200,
          accountUuid: 'acc-1',
          toAccountUuid: 'acc-2',
        );

        final change = service.calculateBalanceChange(tx, 'acc-1');

        expect(change, -200);
      });

      test('transfer increases destination account balance', () {
        final tx = createTransaction(
          type: TransactionType.transfer,
          amount: 200,
          accountUuid: 'acc-1',
          toAccountUuid: 'acc-2',
        );

        final change = service.calculateBalanceChange(tx, 'acc-2');

        expect(change, 200);
      });

      test('returns 0 for unrelated account', () {
        final tx = createTransaction(
          type: TransactionType.expense,
          amount: 100,
          accountUuid: 'acc-1',
        );

        final change = service.calculateBalanceChange(tx, 'acc-other');

        expect(change, 0);
      });

      test('reverse flag inverts expense effect', () {
        final tx = createTransaction(
          type: TransactionType.expense,
          amount: 100,
        );

        final change = service.calculateBalanceChange(
          tx,
          'acc-1',
          reverse: true,
        );

        expect(change, 100);
      });

      test('reverse flag inverts income effect', () {
        final tx = createTransaction(
          type: TransactionType.income,
          amount: 500,
        );

        final change = service.calculateBalanceChange(
          tx,
          'acc-1',
          reverse: true,
        );

        expect(change, -500);
      });
    });

    group('calculateAllBalanceChanges', () {
      test('returns single entry for expense', () {
        final tx = createTransaction(
          type: TransactionType.expense,
          amount: 100,
        );

        final changes = service.calculateAllBalanceChanges(tx);

        expect(changes.length, 1);
        expect(changes['acc-1'], -100);
      });

      test('returns single entry for income', () {
        final tx = createTransaction(
          type: TransactionType.income,
          amount: 500,
        );

        final changes = service.calculateAllBalanceChanges(tx);

        expect(changes.length, 1);
        expect(changes['acc-1'], 500);
      });

      test('returns two entries for transfer', () {
        final tx = createTransaction(
          type: TransactionType.transfer,
          amount: 200,
          accountUuid: 'acc-1',
          toAccountUuid: 'acc-2',
        );

        final changes = service.calculateAllBalanceChanges(tx);

        expect(changes.length, 2);
        expect(changes['acc-1'], -200);
        expect(changes['acc-2'], 200);
      });

      test('reverse flag inverts all changes', () {
        final tx = createTransaction(
          type: TransactionType.transfer,
          amount: 200,
          accountUuid: 'acc-1',
          toAccountUuid: 'acc-2',
        );

        final changes = service.calculateAllBalanceChanges(tx, reverse: true);

        expect(changes['acc-1'], 200);
        expect(changes['acc-2'], -200);
      });
    });

    group('calculateTotalBalance', () {
      test('calculates balance from multiple transactions', () {
        final transactions = [
          createTransaction(
            type: TransactionType.income,
            amount: 1000,
            accountUuid: 'acc-1',
          ),
          createTransaction(
            type: TransactionType.expense,
            amount: 300,
            accountUuid: 'acc-1',
          ),
          createTransaction(
            type: TransactionType.expense,
            amount: 200,
            accountUuid: 'acc-1',
          ),
        ];

        final balance = service.calculateTotalBalance(
          transactions,
          'acc-1',
          0,
        );

        expect(balance, 500); // 1000 - 300 - 200
      });

      test('includes initial balance', () {
        final transactions = [
          createTransaction(
            type: TransactionType.expense,
            amount: 100,
            accountUuid: 'acc-1',
          ),
        ];

        final balance = service.calculateTotalBalance(
          transactions,
          'acc-1',
          500, // initial balance
        );

        expect(balance, 400); // 500 - 100
      });

      test('handles transfers correctly', () {
        final transactions = [
          createTransaction(
            type: TransactionType.transfer,
            amount: 300,
            accountUuid: 'acc-1',
            toAccountUuid: 'acc-2',
          ),
        ];

        final acc1Balance = service.calculateTotalBalance(
          transactions,
          'acc-1',
          1000,
        );
        final acc2Balance = service.calculateTotalBalance(
          transactions,
          'acc-2',
          500,
        );

        expect(acc1Balance, 700); // 1000 - 300
        expect(acc2Balance, 800); // 500 + 300
      });

      test('ignores unrelated transactions', () {
        final transactions = [
          createTransaction(
            type: TransactionType.expense,
            amount: 100,
            accountUuid: 'acc-other',
          ),
        ];

        final balance = service.calculateTotalBalance(
          transactions,
          'acc-1',
          500,
        );

        expect(balance, 500); // unchanged
      });
    });

    group('calculateEditChanges', () {
      test('calculates changes when amount changes', () {
        final oldTx = createTransaction(
          type: TransactionType.expense,
          amount: 100,
        );
        final newTx = createTransaction(
          type: TransactionType.expense,
          amount: 150,
        );

        final changes = service.calculateEditChanges(oldTx, newTx);

        // Reverse old (-100 reversed = +100)
        // Apply new (-150)
        // Net: +100 - 150 = -50
        expect(changes['acc-1'], -50);
      });

      test('calculates changes when type changes', () {
        final oldTx = createTransaction(
          type: TransactionType.expense,
          amount: 100,
        );
        final newTx = createTransaction(
          type: TransactionType.income,
          amount: 100,
        );

        final changes = service.calculateEditChanges(oldTx, newTx);

        // Reverse expense (+100) + apply income (+100) = +200
        expect(changes['acc-1'], 200);
      });

      test('calculates changes when account changes', () {
        final oldTx = createTransaction(
          type: TransactionType.expense,
          amount: 100,
          accountUuid: 'acc-1',
        );
        final newTx = TransactionEntity(
          uuid: 'tx-1',
          amount: 100,
          currency: 'USD',
          type: TransactionType.expense,
          categoryUuid: 'cat-1',
          accountUuid: 'acc-2',
          date: DateTime.now(),
          createdDate: DateTime.now(),
        );

        final changes = service.calculateEditChanges(oldTx, newTx);

        expect(changes['acc-1'], 100); // reversed
        expect(changes['acc-2'], -100); // applied
      });

      test('removes zero changes from result', () {
        final tx = createTransaction(
          type: TransactionType.expense,
          amount: 100,
        );

        final changes = service.calculateEditChanges(tx, tx);

        expect(changes.isEmpty, isTrue);
      });
    });
  });
}
