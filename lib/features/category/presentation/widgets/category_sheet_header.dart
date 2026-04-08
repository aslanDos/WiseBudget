import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/circle_icon_button.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

/// Shared header used by both [CategoriesPage] and [CategoryForm].
/// Renders a close button, an expense/income type toggle, and a [trailing] slot.
class CategorySheetHeader extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;
  final Widget trailing;

  const CategorySheetHeader({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.trailing,
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: TypeToggle<TransactionType>(
                    items: TransactionType.values
                        .where((t) => t != TransactionType.transfer)
                        .map(
                          (t) => TypeToggleItem(
                            value: t,
                            label: t.label,
                            icon: t.icon,
                            selectedBackgroundColor:
                                t.actionBackgroundColor(context),
                            selectedForegroundColor: t.actionColor(context),
                          ),
                        )
                        .toList(),
                    selected: selectedType,
                    onChanged: onTypeChanged,
                  ),
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
