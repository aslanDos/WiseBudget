import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';

class HomeTab extends StatelessWidget {
  final ScrollController? scrollController;
  const HomeTab({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(AppIcons.settings),
        centerTitle: true,
        title: Text('Home'),
      ),
      body: Container(child: Center(child: Text('Home Tab'))),
    );
  }
}
