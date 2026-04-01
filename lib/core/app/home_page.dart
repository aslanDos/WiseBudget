import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form.dart';
import 'package:wisebuget/core/shared/widgets/frame.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/core/app/pages/account_tab.dart';
import 'package:wisebuget/core/app/pages/home_tab.dart';
import 'package:wisebuget/core/app/pages/analytics_tab.dart';
import 'package:wisebuget/features/navbar/presentation/navbar.dart';
import 'package:wisebuget/features/navbar/presentation/widgets/new_transaction_button.dart';
import 'package:wisebuget/core/app/pages/tools_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
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
      child: Stack(
        children: [
          Scaffold(
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
          ),
          Positioned(
            bottom: 4.0,
            left: 0.0,
            right: 0.0,
            child: SafeArea(
              child: Frame(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Navbar(
                      onTap: (i) => _navigateTo(i),
                      activeIndex: _currentIndex,
                    ),
                    NewTransactionButton(
                      onActionTap: (type) => _onNewTransaction(type),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
