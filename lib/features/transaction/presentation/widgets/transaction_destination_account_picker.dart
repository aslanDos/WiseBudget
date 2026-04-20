import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/entity_picker_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
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
        ? AppPalette.fromValue(selectedAccount!.colorValue, defaultColor: context.c.primary)
        : context.c.primary;

    return PickerField(
      icon: selectedAccount != null ? AppIcons.fromCode(selectedAccount!.iconCode) : AppIcons.circle,
      iconColor: iconColor,
      label: selectedAccount?.name ?? context.l10n.selectDestination,
      shrink: true,
      showChevron: false,
      onTap: () => showEntityPickerSheet(
        context: context,
        items: accounts,
        title: context.l10n.selectDestinationAccount,
        selectedId: selectedAccount?.uuid,
        getId: (a) => a.uuid,
        getTitle: (a) => a.name,
        getSubtitle: (a) => a.money.formatted,
        getIcon: (a) => AppIcons.fromCode(a.iconCode),
        getColor: (ctx, a) => AppPalette.fromValue(a.colorValue, defaultColor: ctx.c.primary),
        onSelected: onSelected,
      ),
    );
  }
}
