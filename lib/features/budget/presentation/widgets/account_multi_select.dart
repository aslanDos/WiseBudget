import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

/// Shows a multi-select modal for accounts
Future<List<String>?> showAccountMultiSelect({
  required BuildContext context,
  required List<AccountEntity> accounts,
  required List<String> selectedUuids,
  String title = 'Select Accounts',
}) {
  return showModal<List<String>>(
    context: context,
    builder: (context) => _AccountMultiSelectSheet(
      accounts: accounts,
      selectedUuids: selectedUuids,
      title: title,
    ),
  );
}

class _AccountMultiSelectSheet extends StatefulWidget {
  final List<AccountEntity> accounts;
  final List<String> selectedUuids;
  final String title;

  const _AccountMultiSelectSheet({
    required this.accounts,
    required this.selectedUuids,
    required this.title,
  });

  @override
  State<_AccountMultiSelectSheet> createState() =>
      _AccountMultiSelectSheetState();
}

class _AccountMultiSelectSheetState extends State<_AccountMultiSelectSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedUuids);
  }

  void _toggleAccount(String uuid) {
    setState(() {
      if (_selected.contains(uuid)) {
        _selected.remove(uuid);
      } else {
        _selected.add(uuid);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ModalSheet.scrollable(
      title: Text(widget.title),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _selected.isEmpty ? null : _clearAll,
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _selected.toList()),
                child: Text(
                  _selected.isEmpty
                      ? 'All Accounts'
                      : 'Done (${_selected.length})',
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // All accounts option
          ListTile(
            leading: Icon(
              Icons.account_balance_wallet_outlined,
              color: colors.primary,
            ),
            title: const Text('All Accounts'),
            subtitle: const Text('Track spending across all accounts'),
            onTap: () => Navigator.pop(context, <String>[]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          const Divider(height: 1, indent: 24, endIndent: 24),

          // Account list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.accounts.length,
            itemBuilder: (context, index) {
              final account = widget.accounts[index];
              final isSelected = _selected.contains(account.uuid);
              final color = AppPalette.fromValue(
                account.colorValue,
                defaultColor: colors.primary,
              );

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(0x26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    AppIcons.fromCode(account.iconCode),
                    color: color,
                    size: 22,
                  ),
                ),
                title: Text(account.name),
                subtitle: Text(account.money.formatted),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleAccount(account.uuid),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onTap: () => _toggleAccount(account.uuid),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Display selected accounts as text
class AccountSelectionText extends StatelessWidget {
  final List<AccountEntity> accounts;
  final List<String> selectedUuids;

  const AccountSelectionText({
    super.key,
    required this.accounts,
    required this.selectedUuids,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (selectedUuids.isEmpty) {
      return Text(
        'All accounts',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );
    }

    final selectedAccounts = accounts
        .where((a) => selectedUuids.contains(a.uuid))
        .toList();

    if (selectedAccounts.length == 1) {
      return Text(
        selectedAccounts.first.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );
    }

    return Text(
      '${selectedAccounts.length} accounts',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
