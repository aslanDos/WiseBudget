import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_list_tile.dart';
import 'package:wisebuget/core/shared/widgets/pressable.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

class AccountChip extends StatelessWidget {
  final AccountEntity? account;
  final Color? backgroundColor;
  final List<AccountEntity> accounts;
  final ValueChanged<String> onSelected;

  /// When provided, an "All Accounts" option is shown at the top of the picker.
  /// Called when the user selects it.
  final VoidCallback? onAllSelected;

  /// Whether "All Accounts" is currently the active selection.
  final bool allSelected;

  const AccountChip({
    super.key,
    required this.account,
    this.backgroundColor,
    required this.accounts,
    required this.onSelected,
    this.onAllSelected,
    this.allSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final showAll = onAllSelected != null;

    final IconData icon;
    final Color iconColor;
    final String label;

    if (showAll && allSelected) {
      icon = AppIcons.wallet;
      iconColor = context.c.primary;
      label = 'All Accounts';
    } else {
      icon = account != null
          ? AppIcons.fromCode(account!.iconCode)
          : AppIcons.wallet;
      iconColor = AppPalette.fromValue(
        account?.colorValue,
        defaultColor: context.c.primary,
      );
      label = account?.name ?? 'Select an account';
    }

    return Pressable(
      onTap: () => showAccountPicker(
        context: context,
        accounts: accounts,
        selectedAccountUuid: allSelected ? null : account?.uuid,
        onSelected: onSelected,
        onAllSelected: onAllSelected,
      ),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? context.c.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(label, style: context.t.titleMedium),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

void showAccountPicker({
  required BuildContext context,
  required List<AccountEntity> accounts,
  required String? selectedAccountUuid,
  required ValueChanged<String> onSelected,
  VoidCallback? onAllSelected,
  String title = 'Select Account',
}) {
  if (accounts.isEmpty) return;

  showModal(
    context: context,
    builder: (context) {
      final isAllSelected = selectedAccountUuid == null;
      return ModalSheet.scrollable(
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: context.t.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onAllSelected != null)
              GestureDetector(
                onTap: () {
                  onAllSelected();
                  Navigator.pop(context);
                },
                child: Text(
                  'All',
                  style: context.t.titleMedium?.copyWith(
                    color: isAllSelected
                        ? context.c.primary
                        : context.c.onSecondary,
                  ),
                ),
              ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            final isSelected = account.uuid == selectedAccountUuid;
            final isMarked = isAllSelected || isSelected;
            final color = AppPalette.fromValue(
              account.colorValue,
              defaultColor: Theme.of(context).colorScheme.primary,
            );

            return PickerListTile(
              icon: AppIcons.fromCode(account.iconCode),
              iconColor: color,
              iconBackgroundColor: color.withAlpha(0x33),
              title: account.name,
              subtitle: account.money.formatted,
              isSelected: isSelected,
              isMarked: isMarked,
              onTap: () {
                onSelected(account.uuid);
                Navigator.pop(context);
              },
            );
          },
        ),
      );
    },
  );
}
