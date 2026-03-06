import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/frame.dart';
import 'package:wisebuget/features/account/presentation/pages/account_tab.dart';
import 'package:wisebuget/features/home/presentation/pages/home_tab.dart';
import 'package:wisebuget/features/analytics/presentation/pages/analytics_tab.dart';
import 'package:wisebuget/features/navbar/presentation/navbar.dart';
import 'package:wisebuget/features/navbar/presentation/widgets/new_transaction_button.dart';
import 'package:wisebuget/features/settings/presentation/pages/settings_tab.dart';

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
    return Stack(
      children: [
        Scaffold(
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              HomeTab(scrollController: _homeTabScrollController),
              const AccountTab(),
              const AnalyticsTab(),
              const SettingsTab(),
            ],
          ),
        ),
        Positioned(
          bottom: 16.0,
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
                  NewTransactionButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateTo(int index) {
    if (index == _tabController.index) {}

    _tabController.animateTo(index);
  }
}
