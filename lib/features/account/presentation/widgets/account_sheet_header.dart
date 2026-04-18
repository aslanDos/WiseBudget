import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class AccountSheetHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onDelete;
  final String title;

  const AccountSheetHeader({
    super.key,
    required this.isEditing,
    required this.onDelete,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            ActionButton(
              backgroundColor: Colors.transparent,
              icon: AppIcons.close,
              onTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(child: Text(title, style: context.t.titleMedium)),
            ),
            if (isEditing)
              ActionButton(
                backgroundColor: Colors.transparent,
                icon: AppIcons.trash,
                onTap: onDelete,
                iconColor: context.c.error,
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}
