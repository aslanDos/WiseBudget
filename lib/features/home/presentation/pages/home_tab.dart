import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  final ScrollController? scrollController;
  const HomeTab({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(child: Center(child: Text('Home Tab')));
  }
}
