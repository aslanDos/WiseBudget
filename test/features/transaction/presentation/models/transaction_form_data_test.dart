import 'package:flutter_test/flutter_test.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/models/transaction_form_data.dart';

void main() {
  group('TransactionFormData', () {
    group('factory fromTransaction', () {
      test('creates empty form for null transaction', () {
        final form = TransactionFormData.fromTransaction(
          null,
          TransactionType.expense,
        );

        expect(form.type, TransactionType.expense);
        expect(form.amount, 0);
        expect(form.accountUuid, isNull);
        expect(form.categoryUuid, isNull);
        expect(form.note, '');
      });

      test('populates form from existing expense transaction', () {
        final transaction = TransactionEntity(
          uuid: 'tx-1',
          amount: 100.50,
          currency: 'USD',
          type: TransactionType.expense,
          categoryUuid: 'cat-1',
          accountUuid: 'acc-1',
          note: 'Test note',
          date: DateTime(2024, 1, 15),
          createdDate: DateTime(2024, 1, 15),
        );

        final form = TransactionFormData.fromTransaction(
          transaction,
          TransactionType.income,
        );

        expect(form.type, TransactionType.expense);
        expect(form.amount, 100.50);
        expect(form.accountUuid, 'acc-1');
        expect(form.expenseCategoryUuid, 'cat-1');
        expect(form.incomeCategoryUuid, isNull);
        expect(form.note, 'Test note');
      });

      test('populates form from existing income transaction', () {
        final transaction = TransactionEntity(
          uuid: 'tx-1',
          amount: 500,
          currency: 'USD',
          type: TransactionType.income,
          categoryUuid: 'cat-income',
          accountUuid: 'acc-1',
          date: DateTime(2024, 1, 15),
          createdDate: DateTime(2024, 1, 15),
        );

        final form = TransactionFormData.fromTransaction(
          transaction,
          TransactionType.expense,
        );

        expect(form.type, TransactionType.income);
        expect(form.incomeCategoryUuid, 'cat-income');
        expect(form.expenseCategoryUuid, isNull);
      });

      test('populates form from transfer transaction', () {
        final transaction = TransactionEntity(
          uuid: 'tx-1',
          amount: 200,
          currency: 'USD',
          type: TransactionType.transfer,
          categoryUuid: '',
          accountUuid: 'acc-1',
          toAccountUuid: 'acc-2',
          date: DateTime(2024, 1, 15),
          createdDate: DateTime(2024, 1, 15),
        );

        final form = TransactionFormData.fromTransaction(
          transaction,
          TransactionType.expense,
        );

        expect(form.type, TransactionType.transfer);
        expect(form.accountUuid, 'acc-1');
        expect(form.toAccountUuid, 'acc-2');
      });
    });

    group('categoryUuid getter/setter', () {
      test('returns expense category for expense type', () {
        final form = TransactionFormData(type: TransactionType.expense);
        form.expenseCategoryUuid = 'expense-cat';
        form.incomeCategoryUuid = 'income-cat';

        expect(form.categoryUuid, 'expense-cat');
      });

      test('returns income category for income type', () {
        final form = TransactionFormData(type: TransactionType.income);
        form.expenseCategoryUuid = 'expense-cat';
        form.incomeCategoryUuid = 'income-cat';

        expect(form.categoryUuid, 'income-cat');
      });

      test('sets expense category for expense type', () {
        final form = TransactionFormData(type: TransactionType.expense);
        form.categoryUuid = 'new-cat';

        expect(form.expenseCategoryUuid, 'new-cat');
        expect(form.incomeCategoryUuid, isNull);
      });

      test('sets income category for income type', () {
        final form = TransactionFormData(type: TransactionType.income);
        form.categoryUuid = 'new-cat';

        expect(form.incomeCategoryUuid, 'new-cat');
        expect(form.expenseCategoryUuid, isNull);
      });
    });

    group('displayAmount', () {
      test('returns "0" for zero amount', () {
        final form = TransactionFormData(type: TransactionType.expense);
        expect(form.displayAmount, '0');
      });

      test('returns whole number without decimals', () {
        final form = TransactionFormData(
          type: TransactionType.expense,
          amount: 100.0,
        );
        expect(form.displayAmount, '100');
      });

      test('trims trailing zeros', () {
        final form = TransactionFormData(
          type: TransactionType.expense,
          amount: 100.50,
        );
        expect(form.displayAmount, '100.5');
      });

      test('keeps significant decimals', () {
        final form = TransactionFormData(
          type: TransactionType.expense,
          amount: 100.05,
        );
        expect(form.displayAmount, '100.05');
      });
    });

    group('validate', () {
      test('returns error for zero amount', () {
        final form = TransactionFormData(
          type: TransactionType.expense,
          amount: 0,
          accountUuid: 'acc-1',
        );
        form.categoryUuid = 'cat-1';

        expect(form.validate(), 'Please enter a valid amount');
      });

      test('returns error for missing account', () {
        final form = TransactionFormData(
          type: TransactionType.expense,
          amount: 100,
        );
        form.categoryUuid = 'cat-1';

        expect(form.validate(), 'Please select an account');
      });

      test('returns error for missing category on expense', () {
        final form = TransactionFormData(
          type: TransactionType.expense,
          amount: 100,
          accountUuid: 'acc-1',
        );

        expect(form.validate(), 'Please select a category');
      });

      test('returns error for missing destination on transfer', () {
        final form = TransactionFormData(
          type: TransactionType.transfer,
          amount: 100,
          accountUuid: 'acc-1',
        );

        expect(form.validate(), 'Please select a destination account');
      });

      test('returns error for same source and destination on transfer', () {
        final form = TransactionFormData(
          type: TransactionType.transfer,
          amount: 100,
          accountUuid: 'acc-1',
          toAccountUuid: 'acc-1',
        );

        expect(
          form.validate(),
          'Source and destination accounts must be different',
        );
      });

      test('returns null for valid expense', () {
        final form = TransactionFormData(
          type: TransactionType.expense,
          amount: 100,
          accountUuid: 'acc-1',
        );
        form.categoryUuid = 'cat-1';

        expect(form.validate(), isNull);
      });

      test('returns null for valid transfer', () {
        final form = TransactionFormData(
          type: TransactionType.transfer,
          amount: 100,
          accountUuid: 'acc-1',
          toAccountUuid: 'acc-2',
        );

        expect(form.validate(), isNull);
      });
    });

    group('filterCategories', () {
      final categories = [
        CategoryEntity(
          uuid: 'cat-1',
          name: 'Food',
          type: TransactionType.expense,
          iconCode: 'food',
          visible: true,
          createdDate: DateTime.now(),
        ),
        CategoryEntity(
          uuid: 'cat-2',
          name: 'Salary',
          type: TransactionType.income,
          iconCode: 'salary',
          visible: true,
          createdDate: DateTime.now(),
        ),
        CategoryEntity(
          uuid: 'cat-3',
          name: 'Hidden',
          type: TransactionType.expense,
          iconCode: 'hidden',
          visible: false,
          createdDate: DateTime.now(),
        ),
      ];

      test('filters expense categories for expense type', () {
        final form = TransactionFormData(type: TransactionType.expense);
        final filtered = form.filterCategories(categories);

        expect(filtered.length, 1);
        expect(filtered.first.uuid, 'cat-1');
      });

      test('filters income categories for income type', () {
        final form = TransactionFormData(type: TransactionType.income);
        final filtered = form.filterCategories(categories);

        expect(filtered.length, 1);
        expect(filtered.first.uuid, 'cat-2');
      });

      test('excludes hidden categories', () {
        final form = TransactionFormData(type: TransactionType.expense);
        final filtered = form.filterCategories(categories);

        expect(filtered.any((c) => c.uuid == 'cat-3'), isFalse);
      });
    });

    group('filterToAccounts', () {
      final accounts = [
        AccountEntity(
          uuid: 'acc-1',
          name: 'Checking',
          balance: 1000,
          currency: 'USD',
          iconCode: 'wallet',
          createdDate: DateTime.now(),
        ),
        AccountEntity(
          uuid: 'acc-2',
          name: 'Savings',
          balance: 5000,
          currency: 'USD',
          iconCode: 'savings',
          createdDate: DateTime.now(),
        ),
      ];

      test('excludes current account from destination list', () {
        final form = TransactionFormData(
          type: TransactionType.transfer,
          accountUuid: 'acc-1',
        );
        final filtered = form.filterToAccounts(accounts);

        expect(filtered.length, 1);
        expect(filtered.first.uuid, 'acc-2');
      });

      test('returns all accounts when no source selected', () {
        final form = TransactionFormData(type: TransactionType.transfer);
        final filtered = form.filterToAccounts(accounts);

        expect(filtered.length, 2);
      });
    });
  });
}
