import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';

class TransactionSaveButton extends StatelessWidget {
  const TransactionSaveButton({
    super.key,
    required this.isEnabled,
    required this.isEditing,
    required this.isRecurring,
    required this.isRecurringDraft,
    required this.isSavingEditWithRecurring,
    required this.onPressed,
    required this.onTransactionStateChanged,
    required this.onRecurringStateChanged,
  });

  final bool isEnabled;
  final bool isEditing;
  final bool isRecurring;
  final bool isRecurringDraft;
  final bool isSavingEditWithRecurring;
  final ValueChanged<BuildContext> onPressed;
  final BlocWidgetListener<TransactionState> onTransactionStateChanged;
  final BlocWidgetListener<RecurringTransactionState> onRecurringStateChanged;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionCubit, TransactionState>(
          listenWhen: (prev, curr) =>
              prev.status == CubitStatus.loading &&
              curr.status != CubitStatus.loading,
          listener: onTransactionStateChanged,
        ),
        BlocListener<RecurringTransactionCubit, RecurringTransactionState>(
          listenWhen: (prev, curr) =>
              prev.status == CubitStatus.loading &&
              curr.status != CubitStatus.loading,
          listener: onRecurringStateChanged,
        ),
      ],
      child: Builder(
        builder: (context) {
          final transactionState = context.watch<TransactionCubit>().state;
          final recurringState = context
              .watch<RecurringTransactionCubit>()
              .state;

          return Button(
            label: _label(context),
            isLoading: _isLoading(transactionState, recurringState),
            onPressed: isEnabled ? () => onPressed(context) : null,
            width: double.infinity,
          );
        },
      ),
    );
  }

  bool _isLoading(
    TransactionState transactionState,
    RecurringTransactionState recurringState,
  ) {
    if (isSavingEditWithRecurring) {
      return transactionState.status == CubitStatus.loading ||
          recurringState.status == CubitStatus.loading;
    }
    if (isRecurring) return recurringState.status == CubitStatus.loading;
    return transactionState.status == CubitStatus.loading;
  }

  String _label(BuildContext context) {
    if (isRecurringDraft) return context.l10n.confirm;
    if (!isRecurring) return context.l10n.save;
    return isEditing
        ? context.l10n.saveAndSchedule
        : context.l10n.saveRecurring;
  }
}
