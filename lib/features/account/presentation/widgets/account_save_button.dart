import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';

class AccountSaveButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onSave;

  const AccountSaveButton({
    super.key,
    required this.isEditing,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listenWhen: (previous, current) =>
          previous.status == CubitStatus.loading &&
          current.status != CubitStatus.loading,
      listener: (context, state) {
        if (state.status == CubitStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == CubitStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Failed to save')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == CubitStatus.loading;
        return FilledButton(
          onPressed: isLoading ? null : onSave,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Save Changes' : 'Create Account'),
        );
      },
    );
  }
}
