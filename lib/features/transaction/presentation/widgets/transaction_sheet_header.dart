import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/account_chip.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';

class TransactionSheetHeader extends StatelessWidget {
  final bool isEditing;
  final String? selectedAccountUuid;
  final ValueChanged<String> onAccountSelected;
  final VoidCallback onDelete;

  const TransactionSheetHeader({
    super.key,
    required this.isEditing,
    required this.selectedAccountUuid,
    required this.onAccountSelected,
    required this.onDelete,
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
                child: BlocBuilder<AccountCubit, AccountState>(
                  builder: (context, state) {
                    final account = state.accounts
                        .where((a) => a.uuid == selectedAccountUuid)
                        .firstOrNull;

                    return AccountChip(
                      backgroundColor: Colors.transparent,
                      account: account,
                      accounts: state.accounts,
                      onSelected: onAccountSelected,
                    );
                  },
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
