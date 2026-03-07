import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/frame.dart';
import 'package:wisebuget/features/tools/data/tool_item.dart';
import 'package:wisebuget/features/tools/presentation/widgets/tool_card.dart';

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(AppIcons.settings),
        centerTitle: true,
        title: const Text('Tools'),
      ),
      body: Frame(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: 1.1,
          ),
          itemCount: ToolItem.items.length,
          itemBuilder: (context, index) {
            final item = ToolItem.items[index];
            return ToolCard(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              iconColor: item.iconColor,
              backgroundColor: item.backgroundColor,
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
