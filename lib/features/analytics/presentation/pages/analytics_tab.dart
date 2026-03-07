import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(AppIcons.settings),
        centerTitle: true,
        title: Text('Analytics'),
      ),
      body: Container(child: Center(child: Text('Analytics Tab'))),
    );
  }
}
