import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisebuget/core/database/objectbox.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/features/account/data/datasource/account_local_datasource.dart';
import 'package:wisebuget/features/account/data/datasource/account_local_datasource_impl.dart';
import 'package:wisebuget/features/account/data/repository/account_repository_impl.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';
import 'package:wisebuget/features/account/domain/usecases/account_usecases.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  final objectBox = await ObjectBox.create();

  // External
  sl.registerLazySingleton(() => sharedPrefs);
  sl.registerLazySingleton(() => objectBox.store);

  // Preferences
  sl.registerSingleton(LocalPreferences(prefs: sl()));

  // Account Feature
  _initAccountFeature();
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

  // Cubit
  sl.registerFactory(() => AccountCubit(
        getAccounts: sl(),
        createAccount: sl(),
        updateAccount: sl(),
        deleteAccount: sl(),
      ));
}
