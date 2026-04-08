import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/circle_icon_button.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

class AccountSheetHeader extends StatelessWidget {
  final Widget trailing;
  final String title;

  const AccountSheetHeader({
    super.key,
    required this.trailing,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.c.onSurface.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            CircleIconButton(
              icon: AppIcons.close,
              onTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(child: Text(title, style: context.t.titleMedium)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
