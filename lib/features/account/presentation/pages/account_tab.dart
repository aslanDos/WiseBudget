import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(AppIcons.settings),
        centerTitle: true,
        title: Text('Accounts'),
      ),
      body: Container(child: Center(child: Text('Account Tab'))),
    );
  }
}
