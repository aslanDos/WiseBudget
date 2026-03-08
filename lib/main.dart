import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/constants/app_constants.dart';
import 'package:wisebuget/core/di/dependency_injection.dart' as di;
import 'package:wisebuget/core/logger/logger_setup.dart';
import 'package:wisebuget/core/router/router.dart';
import 'package:wisebuget/core/theme/app_theme.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';

final _log = Logger('Main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();
  await di.init();
  runApp(const WiseBudget());
}

class WiseBudget extends StatefulWidget {
  const WiseBudget({super.key});

  @override
  State<WiseBudget> createState() => _WiseBudgetState();
}

class _WiseBudgetState extends State<WiseBudget> {
  @override
  void initState() {
    super.initState();
    _seedDefaultData();
  }

  Future<void> _seedDefaultData() async {
    _log.info('Seeding default data');
    await di.sl<AccountCubit>().seedDefaultAccount();
    await di.sl<CategoryCubit>().seedDefaultCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      darkTheme: AppTheme.dark,
      theme: AppTheme.light,
      title: AppConstants.appName,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
