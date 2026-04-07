import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/frame.dart';
import 'package:wisebuget/features/category/presentation/pages/categories_page.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            tooltip: 'Clear All Data',
            onPressed: () => _showClearDataDialog(context),
          ),
        ],
      ),
      body: Frame(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: 0.95,
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
              onTap: () {
                if (item.route == AppRoutes.manageCategories) {
                  showCategoriesModal(context: context);
                } else if (item.route != null) {
                  context.push(item.route!);
                }
              },
            );
          },
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: colorScheme.error,
          size: 48,
        ),
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your accounts, categories, '
          'and transactions. The app will restart as if freshly installed.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _clearAllData(context);
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Close the ObjectBox store first
      final store = sl<Store>();
      store.close();

      // Delete the ObjectBox database directory
      final docsDir = await getApplicationDocumentsDirectory();
      final objectBoxDir = Directory(p.join(docsDir.path, 'objectbox'));
      if (await objectBoxDir.exists()) {
        await objectBoxDir.delete(recursive: true);
      }

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Close the app - user will need to reopen it
      // This is the cleanest way to ensure a fresh start
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success message and exit
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Data Cleared'),
            content: const Text(
              'All data has been cleared. The app will now close. '
              'Please reopen it to start fresh.',
            ),
            actions: [
              FilledButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Close App'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear data: $e')),
        );
      }
    }
  }
}
