import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_list_tile.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

class AccountChip extends StatelessWidget {
  final AccountEntity? account;
  final List<AccountEntity> accounts;
  final ValueChanged<String> onSelected;

  const AccountChip({
    super.key,
    required this.account,
    required this.accounts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final icon = account != null
        ? AppIcons.fromCode(account!.iconCode)
        : AppIcons.wallet;

    final iconColor = AppPalette.fromValue(
      account?.colorValue,
      defaultColor: context.c.primary,
    );

    return GestureDetector(
      onTap: () => showAccountPicker(
        context: context,
        accounts: accounts,
        selectedAccountUuid: account?.uuid,
        onSelected: onSelected,
      ),
      child: Container(
        // To make as high as header buttons
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.c.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              account?.name ?? 'Select an account',
              style: context.t.titleSmall,
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16),
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
  String title = 'Select Account',
}) {
  if (accounts.isEmpty) return;

  showModal(
    context: context,
    builder: (context) => ModalSheet.scrollable(
      title: Text(title, style: context.t.titleMedium),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          final isSelected = account.uuid == selectedAccountUuid;
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
            onTap: () {
              onSelected(account.uuid);
              Navigator.pop(context);
            },
          );
        },
      ),
    ),
  );
}
