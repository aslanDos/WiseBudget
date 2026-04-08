import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/shared/widgets/picker_list_tile.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

class TransactionDestinationAccountPicker extends StatelessWidget {
  final AccountEntity? selectedAccount;
  final List<AccountEntity> accounts;
  final ValueChanged<String> onSelected;

  const TransactionDestinationAccountPicker({
    super.key,
    required this.selectedAccount,
    required this.accounts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = selectedAccount != null
        ? AppPalette.fromValue(
            selectedAccount!.colorValue,
            defaultColor: context.c.primary,
          )
        : context.c.primary;

    return PickerField(
      icon: selectedAccount != null
          ? AppIcons.fromCode(selectedAccount!.iconCode)
          : AppIcons.circle,
      iconColor: iconColor,
      label: selectedAccount?.name ?? 'Select destination',
      shrink: true,
      showChevron: false,
      onTap: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    if (accounts.isEmpty) return;

    showModal(
      context: context,
      builder: (context) => ModalSheet.scrollable(
        title: const Text('Select Destination Account'),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            final isSelected = account.uuid == selectedAccount?.uuid;
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
}
