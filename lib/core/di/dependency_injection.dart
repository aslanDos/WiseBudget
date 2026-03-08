import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisebuget/core/database/objectbox.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/features/account/data/data_source/account_local_datasource.dart';
import 'package:wisebuget/features/account/data/data_source/account_local_datasource_impl.dart';
import 'package:wisebuget/features/account/data/repository/account_repository_impl.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';
import 'package:wisebuget/features/account/domain/usecases/account_usecases.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/category/data/data_source/category_local_datasource.dart';
import 'package:wisebuget/features/category/data/data_source/category_local_datasource_impl.dart';
import 'package:wisebuget/features/category/data/repository/category_repository_impl.dart';
import 'package:wisebuget/features/category/domain/repository/category_repository.dart';
import 'package:wisebuget/features/category/domain/usecases/category_usecases.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  final objectBox = await ObjectBox.create();

  // External
  sl.registerLazySingleton(() => sharedPrefs);
  sl.registerLazySingleton(() => objectBox.store);

  // Preferences
  sl.registerSingleton(LocalPreferences(prefs: sl()));

  // Features
  _initAccountFeature();
  _initCategoryFeature();
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
  sl.registerLazySingleton(() => SeedDefaultAccount(sl()));

  // Cubit
  sl.registerFactory(
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
  sl.registerFactory(
    () => CategoryCubit(
      getCategories: sl(),
      createCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
      seedDefaultCategories: sl(),
    ),
  );
}
