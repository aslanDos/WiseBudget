import 'package:flutter_test/flutter_test.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/domain/usecases/build_budget_overview.dart';
import 'package:wisebuget/features/budget/domain/usecases/budget_usecases.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

void main() {
  group('BuildBudgetOverview', () {
    final useCase = BuildBudgetOverview(CalculateBudgetProgress());

    TransactionEntity expense({
      required String uuid,
      required String categoryUuid,
      required double amount,
      required DateTime date,
    }) {
      return TransactionEntity(
        uuid: uuid,
        amount: amount,
        currency: 'USD',
        type: TransactionType.expense,
        categoryUuid: categoryUuid,
        accountUuid: 'cash',
        date: date,
        createdDate: date,
      );
    }

    test('aggregates totals and generates exceeded insight', () async {
      final budgets = [
        BudgetEntity(
          uuid: 'food-budget',
          name: 'Food',
          limit: 100,
          currency: 'USD',
          period: BudgetPeriod.custom,
          startDate: DateTime(2026, 4, 1),
          endDate: DateTime(2026, 4, 30, 23, 59, 59),
          categoryUuids: const ['food'],
          iconCode: 'coffee',
          colorValue: 0xFFFF0000,
          createdDate: DateTime(2026, 4, 1),
        ),
        BudgetEntity(
          uuid: 'transport-budget',
          name: 'Transport',
          limit: 200,
          currency: 'USD',
          period: BudgetPeriod.custom,
          startDate: DateTime(2026, 4, 1),
          endDate: DateTime(2026, 4, 30, 23, 59, 59),
          categoryUuids: const ['transport'],
          iconCode: 'car',
          colorValue: 0xFF00FF00,
          createdDate: DateTime(2026, 4, 1),
        ),
      ];

      final result = await useCase(
        BuildBudgetOverviewParams(
          budgets: budgets,
          transactions: [
            expense(
              uuid: 'food-1',
              categoryUuid: 'food',
              amount: 120,
              date: DateTime(2026, 4, 10),
            ),
            expense(
              uuid: 'transport-1',
              categoryUuid: 'transport',
              amount: 50,
              date: DateTime(2026, 4, 11),
            ),
          ],
        ),
      );

      expect(result.isRight(), isTrue);

      final overview = result.getOrElse(
        () => throw StateError('Expected successful overview'),
      );

      expect(overview.budgets, hasLength(2));
      expect(overview.totalBudget, isNotNull);
      expect(overview.totalBudget!.spent, 170);
      expect(overview.totalBudget!.budget.limit, 300);
      expect(
        overview.insights.any((item) => item.budgetUuid == 'food-budget'),
        isTrue,
      );
    });
  });
}
