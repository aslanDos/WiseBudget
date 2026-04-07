import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/account_chip.dart';
import 'package:wisebuget/core/shared/widgets/circle_icon_button.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';

class FormHeader extends StatelessWidget {
  final bool isEditing;
  final String? selectedAccountUuid;
  final ValueChanged<String> onAccountSelected;
  final VoidCallback onDelete;

  const FormHeader({
    super.key,
    required this.isEditing,
    required this.selectedAccountUuid,
    required this.onAccountSelected,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.c.onSurface.withValues(alpha: 0.3),
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
            Expanded(child: Center(child: _buildAccountSelector(context))),
            if (isEditing)
              CircleIconButton(
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

  Widget _buildAccountSelector(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final account = state.accounts
            .where((a) => a.uuid == selectedAccountUuid)
            .firstOrNull;

        return AccountChip(
          account: account,
          accounts: state.accounts,
          onSelected: onAccountSelected,
        );
      },
    );
  }
}
