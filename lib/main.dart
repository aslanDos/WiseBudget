import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_constants.dart';
import 'package:wisebuget/core/di/dependency_injection.dart' as di;
import 'package:wisebuget/core/logger/logger_setup.dart';
import 'package:wisebuget/core/router/router.dart';
import 'package:wisebuget/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();
  await di.init();
  runApp(const WiseBudget());
}

class WiseBudget extends StatelessWidget {
  const WiseBudget({super.key});

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
