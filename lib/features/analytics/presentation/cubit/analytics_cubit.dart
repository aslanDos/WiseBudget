import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';
import 'package:wisebuget/features/analytics/domain/usecases/build_analytics_report.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/domain/usecases/category_usecases.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/usecases/transaction_usecases.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final GetTransactions _getTransactions;
  final GetCategories _getCategories;
  final BuildAnalyticsReport _buildReport;
  final LocalPreferences _prefs;
  List<TransactionEntity> _transactions = const [];
  List<CategoryEntity> _categories = const [];

  AnalyticsCubit({
    required GetTransactions getTransactions,
    required GetCategories getCategories,
    required BuildAnalyticsReport buildReport,
    required LocalPreferences prefs,
  }) : _getTransactions = getTransactions,
       _getCategories = getCategories,
       _buildReport = buildReport,
       _prefs = prefs,
       super(const AnalyticsState());

  // ─────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    emit(state.copyWith(status: CubitStatus.loading));

    final transactionsResult = await _getTransactions(const NoParams());
    final categoriesResult = await _getCategories(const NoParams());

    final failure =
        transactionsResult.fold((item) => item, (_) => null) ??
        categoriesResult.fold((item) => item, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    _transactions = transactionsResult.getOrElse(() => const []);
    _categories = categoriesResult.getOrElse(() => const []);

    _recompute();
  }

  void selectPeriod(AnalyticsPeriod period) {
    emit(state.copyWith(selectedPeriod: period));
    _recompute();
  }

  void selectAccount(String? accountUuid) {
    emit(state.copyWith(selectedAccountUuid: () => accountUuid));
    _recompute();
  }

  void selectCategoryType(TransactionType type) {
    emit(state.copyWith(categoryType: type));
    _recompute();
  }

  // ─────────────────────────────────────────────────────────────────────────

  void _recompute() {
    final report = _buildReport(
      transactions: _transactions,
      categories: _categories,
      period: state.selectedPeriod,
      categoryType: state.categoryType,
      selectedAccountUuid: state.selectedAccountUuid,
      currency: _prefs.currency,
    );

    emit(
      state.copyWith(
        status: CubitStatus.success,
        barBuckets: report.barBuckets
            .map(
              (item) => BarBucket(
                label: item.label,
                income: item.income,
                expense: item.expense,
                currency: item.currency,
              ),
            )
            .toList(),
        categoryBreakdown: report.categoryBreakdown
            .map(
              (item) => CategoryData(
                categoryUuid: item.categoryUuid,
                name: item.name,
                color: item.color,
                icon: item.icon,
                amount: item.amount,
                currency: item.currency,
                percentage: item.percentage,
              ),
            )
            .toList(),
        totalIncome: report.totalIncome,
        totalExpense: report.totalExpense,
        currency: report.currency,
      ),
    );
  }
}
