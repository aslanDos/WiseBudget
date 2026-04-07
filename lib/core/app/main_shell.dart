import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/widgets/navbar/navbar.dart';
import 'package:wisebuget/core/shared/widgets/navbar/new_transaction_button.dart';
import 'package:wisebuget/core/theme/navbar_theme.dart';
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/core/app/pages/account_tab.dart';
import 'package:wisebuget/core/app/pages/home_tab.dart';
import 'package:wisebuget/core/app/pages/analytics_tab.dart';
import 'package:wisebuget/core/app/pages/tools_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _homeTabScrollController = ScrollController();
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _tabController = TabController(
      vsync: this,
      length: 4,
      initialIndex: _currentIndex,
    );
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: context.pieTheme,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            HomeTab(scrollController: _homeTabScrollController),
            const AccountTab(),
            const AnalyticsTab(),
            const ToolsTab(),
          ],
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            final bottom = MediaQuery.of(context).padding.bottom;

            return SizedBox(
              height: NavbarTheme.height + bottom,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // 👉 Navbar с учётом safe area
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottom),
                      child: Navbar(
                        onTap: (i) => _navigateTo(i),
                        activeIndex: _currentIndex,
                      ),
                    ),
                  ),

                  // 👉 FAB теперь тоже учитывает safe area
                  Positioned(
                    bottom: bottom + NavbarTheme.height / 2 - 16,
                    child: NewTransactionButton(
                      onActionTap: (type) => _onNewTransaction(type),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    if (index == _tabController.index) {}
    _tabController.animateTo(index);
  }

  void _onNewTransaction(TransactionType type) {
    showTransactionFormModal(context: context, initialType: type);
  }
}
