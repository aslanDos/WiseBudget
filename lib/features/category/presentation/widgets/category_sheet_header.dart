import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

/// Shared header used by both [CategoriesPage] and [CategoryForm].
/// Renders a close button, an expense/income type toggle, and a [trailing] slot.
class CategorySheetHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onDelete;
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const CategorySheetHeader({
    super.key,
    required this.isEditing,
    required this.onDelete,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                            selectedBackgroundColor: t.backgroundColor,
                            selectedForegroundColor: t.backgroundColor,
                          ),
                        )
                        .toList(),
                    selected: selectedType,
                    onChanged: onTypeChanged,
                  ),
                ),
              ),
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
