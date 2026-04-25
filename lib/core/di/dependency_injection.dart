import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisebuget/core/database/objectbox.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/services/network_service.dart';
import 'package:wisebuget/features/account/data/data_source/account_local_datasource.dart';
import 'package:wisebuget/features/account/data/data_source/account_local_datasource_impl.dart';
import 'package:wisebuget/features/account/data/repository/account_repository_impl.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';
import 'package:wisebuget/features/account/domain/usecases/account_usecases.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/budget/data/data_source/budget_local_datasource.dart';
import 'package:wisebuget/features/budget/data/data_source/budget_local_datasource_impl.dart';
import 'package:wisebuget/features/budget/data/repository/budget_repository_impl.dart';
import 'package:wisebuget/features/budget/domain/repository/budget_repository.dart';
import 'package:wisebuget/features/budget/domain/usecases/budget_usecases.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/category_detail_cubit.dart';
import 'package:wisebuget/features/analytics/domain/usecases/build_analytics_report.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:wisebuget/features/category/data/data_source/category_local_datasource.dart';
import 'package:wisebuget/features/category/data/data_source/category_local_datasource_impl.dart';
import 'package:wisebuget/features/category/data/repository/category_repository_impl.dart';
import 'package:wisebuget/features/category/domain/repository/category_repository.dart';
import 'package:wisebuget/features/category/domain/usecases/category_usecases.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/exchange_rate/data/data_source/exchange_rate_local_datasource.dart';
import 'package:wisebuget/features/exchange_rate/data/data_source/exchange_rate_remote_datasource.dart';
import 'package:wisebuget/features/exchange_rate/data/repository/exchange_rate_repository_impl.dart';
import 'package:wisebuget/features/exchange_rate/domain/repository/exchange_rate_repository.dart';
import 'package:wisebuget/features/exchange_rate/domain/usecases/get_or_fetch_exchange_rate.dart';
import 'package:wisebuget/features/transaction/data/data_source/transaction_local_datasource.dart';
import 'package:wisebuget/features/transaction/data/data_source/transaction_local_datasource_impl.dart';
import 'package:wisebuget/features/transaction/data/data_source/recurring_transaction_local_datasource.dart';
import 'package:wisebuget/features/transaction/data/data_source/recurring_transaction_local_datasource_impl.dart';
import 'package:wisebuget/features/transaction/data/repository/objectbox_transaction_effects_gateway.dart';
import 'package:wisebuget/features/transaction/data/repository/recurring_transaction_repository_impl.dart';
import 'package:wisebuget/features/transaction/data/repository/transaction_repository_impl.dart';
import 'package:wisebuget/features/transaction/domain/repository/recurring_transaction_repository.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_effects_gateway.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_repository.dart';
import 'package:wisebuget/features/transaction/domain/services/recurring_transaction_scheduler.dart';
import 'package:wisebuget/features/transaction/domain/usecases/recurring_transaction_usecases.dart';
import 'package:wisebuget/features/transaction/domain/usecases/transaction_usecases.dart';
import 'package:wisebuget/core/usecases/clear_all_data.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/budget/domain/usecases/build_budget_overview.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  final objectBox = await ObjectBox.create();

  // External
  sl.registerLazySingleton(() => sharedPrefs);
  sl.registerLazySingleton(() => objectBox.store);

  // Preferences
  sl.registerSingleton(LocalPreferences(prefs: sl()));

  // Network
  sl.registerLazySingleton(() => NetworkService());

  // Settings
  sl.registerLazySingleton(() => ClearAllData(sl()));
  sl.registerLazySingleton(() => SettingsCubit(sl(), sl()));

  // Features
  _initAccountFeature();
  _initCategoryFeature();
  _initExchangeRateFeature();
  _initTransactionFeature();
  _initBudgetFeature();
  _initAnalyticsFeature();
}

void _initExchangeRateFeature() {
  sl.registerLazySingleton<ExchangeRateLocalDataSource>(
    () => ExchangeRateLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ExchangeRateRemoteDataSource>(
    () => FrankfurterRemoteDataSource(networkService: sl()),
  );
  sl.registerLazySingleton<ExchangeRateRepository>(
    () => ExchangeRateRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetOrFetchExchangeRate(sl()));
}

void _initAnalyticsFeature() {
  sl.registerLazySingleton(() => const BuildAnalyticsReport());
  sl.registerFactory(
    () => AnalyticsCubit(
      getTransactions: sl(),
      getCategories: sl(),
      buildReport: sl(),
      prefs: sl(),
    ),
  );
  sl.registerFactory(
    () => CategoryDetailCubit(getTransactionsByCategory: sl()),
  );
}

void _initAccountFeature() {
  // Data sources
  sl.registerLazySingleton<AccountLocalDataSource>(
    () => AccountLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAccounts(sl()));
  sl.registerLazySingleton(() => GetAccountById(sl()));
  sl.registerLazySingleton(() => CreateAccount(sl()));
  sl.registerLazySingleton(() => UpdateAccount(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(() => RecalculateAccountBalances(sl()));
  sl.registerLazySingleton(() => SeedDefaultAccount(sl()));

  // Cubit (singleton so all screens share the same state)
  sl.registerLazySingleton(
    () => AccountCubit(
      getAccounts: sl(),
      createAccount: sl(),
      updateAccount: sl(),
      deleteAccount: sl(),
      seedDefaultAccount: sl(),
    ),
  );
}

void _initCategoryFeature() {
  // Data sources
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetCategoryById(sl()));
  sl.registerLazySingleton(() => CreateCategory(sl()));
  sl.registerLazySingleton(() => UpdateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerLazySingleton(() => SeedDefaultCategories(sl()));

  // Cubit
  sl.registerLazySingleton(
    () => CategoryCubit(
      getCategories: sl(),
      createCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
      seedDefaultCategories: sl(),
    ),
  );
}

void _initTransactionFeature() {
  // Data sources
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<RecurringTransactionLocalDataSource>(
    () => RecurringTransactionLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<RecurringTransactionRepository>(
    () => RecurringTransactionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TransactionEffectsGateway>(
    () => ObjectBoxTransactionEffectsGateway(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => GetTransactionById(sl()));
  sl.registerLazySingleton(() => GetTransactionsByAccount(sl()));
  sl.registerLazySingleton(() => GetTransactionsByCategory(sl()));
  sl.registerLazySingleton(() => CreateTransaction(sl()));
  sl.registerLazySingleton(() => CreateTransactionWithEffects(sl()));
  sl.registerLazySingleton(() => GetRecurringTransactions(sl()));
  sl.registerLazySingleton(() => CreateRecurringTransaction(sl()));
  sl.registerLazySingleton(() => UpdateRecurringTransaction(sl()));
  sl.registerLazySingleton(() => DeleteRecurringTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransactionWithEffects(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransactionWithEffects(sl()));
  sl.registerLazySingleton(() => const RecurringTransactionScheduler());

  // Cubit (singleton so all screens share the same state)
  sl.registerLazySingleton(
    () => TransactionCubit(
      getTransactions: sl(),
      getTransactionsByAccount: sl(),
      getTransactionsByCategory: sl(),
      createTransactionWithEffects: sl(),
      updateTransactionWithEffects: sl(),
      deleteTransactionWithEffects: sl(),
      getOrFetchExchangeRate: sl(),
      recalculateAccountBalances: sl(),
      prefs: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => RecurringTransactionCubit(
      getRecurringTransactions: sl(),
      createRecurringTransaction: sl(),
      updateRecurringTransaction: sl(),
      deleteRecurringTransaction: sl(),
    ),
  );
}

void _initBudgetFeature() {
  // Data sources
  sl.registerLazySingleton<BudgetLocalDataSource>(
    () => BudgetLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBudgets(sl()));
  sl.registerLazySingleton(() => GetBudgetById(sl()));
  sl.registerLazySingleton(() => CreateBudget(sl()));
  sl.registerLazySingleton(() => UpdateBudget(sl()));
  sl.registerLazySingleton(() => DeleteBudget(sl()));
  sl.registerLazySingleton(() => CalculateBudgetProgress());
  sl.registerLazySingleton(() => BuildBudgetOverview(sl()));

  // Cubit
  sl.registerFactory(
    () => BudgetCubit(
      getBudgets: sl(),
      getTransactions: sl(),
      createBudget: sl(),
      updateBudget: sl(),
      deleteBudget: sl(),
      buildOverview: sl(),
    ),
  );
}
