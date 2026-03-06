import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPrefs = await SharedPreferences.getInstance();

  // External
  sl.registerLazySingleton(() => sharedPrefs);

  sl.registerSingleton(() => LocalPreferences(prefs: sl()));
}
