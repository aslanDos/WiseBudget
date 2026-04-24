import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';
import 'package:wisebuget/features/analytics/domain/usecases/build_analytics_report.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

void main() {
  group('BuildAnalyticsReport', () {
    const useCase = BuildAnalyticsReport();

    final categories = [
      CategoryEntity(
        uuid: 'food',
        name: 'Food',
        iconCode: 'coffee',
        createdDate: DateTime(2026, 1, 1),
        type: TransactionType.expense,
        colorValue: 0xFFFF0000,
      ),
      CategoryEntity(
        uuid: 'salary',
        name: 'Salary',
        iconCode: 'wallet',
        createdDate: DateTime(2026, 1, 1),
        type: TransactionType.income,
        colorValue: 0xFF00FF00,
      ),
    ];

    TransactionEntity transaction({
      required String uuid,
      required double amount,
      required TransactionType type,
      required String categoryUuid,
      required String accountUuid,
      String? toAccountUuid,
      required DateTime date,
    }) {
      return TransactionEntity(
        uuid: uuid,
        amount: amount,
        currency: 'USD',
        type: type,
        categoryUuid: categoryUuid,
        accountUuid: accountUuid,
        toAccountUuid: toAccountUuid,
        date: date,
        createdDate: date,
      );
    }

    test('filters by account and builds totals and category breakdown', () {
      final report = useCase(
        transactions: [
          transaction(
            uuid: 't1',
            amount: 100,
            type: TransactionType.expense,
            categoryUuid: 'food',
            accountUuid: 'cash',
            date: DateTime(2026, 4, 10, 10),
          ),
          transaction(
            uuid: 't2',
            amount: 900,
            type: TransactionType.income,
            categoryUuid: 'salary',
            accountUuid: 'cash',
            date: DateTime(2026, 4, 11, 10),
          ),
          transaction(
            uuid: 't3',
            amount: 50,
            type: TransactionType.transfer,
            categoryUuid: 'food',
            accountUuid: 'bank',
            toAccountUuid: 'cash',
            date: DateTime(2026, 4, 12, 10),
          ),
          transaction(
            uuid: 'outside',
            amount: 400,
            type: TransactionType.expense,
            categoryUuid: 'food',
            accountUuid: 'cash',
            date: DateTime(2026, 3, 1, 10),
          ),
        ],
        categories: categories,
        period: CustomPeriod(
          start: DateTime(2026, 4, 1),
          end: DateTime(2026, 4, 30, 23, 59, 59),
        ),
        categoryType: TransactionType.expense,
        currency: 'USD',
        selectedAccountUuid: 'cash',
      );

      expect(report.totalExpense, 100);
      expect(report.totalIncome, 900);
      expect(report.categoryBreakdown, hasLength(1));
      expect(report.categoryBreakdown.first.name, 'Food');
      expect(report.categoryBreakdown.first.color, const Color(0xFFFF0000));
      expect(report.barBuckets, isNotEmpty);
    });
  });
}
