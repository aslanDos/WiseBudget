import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class ModalHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onDelete;

  const ModalHeader({super.key, required this.isEditing, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.c.onSurface.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            ActionButton(
              icon: AppIcons.close,
              onTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text(
                  isEditing ? 'Edit Budget' : 'New Budget',
                  style: context.t.titleMedium,
                ),
              ),
            ),
            if (onDelete != null)
              ActionButton(
                icon: AppIcons.trash,
                onTap: onDelete!,
                iconColor: context.c.error,
              )
            else
              const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
