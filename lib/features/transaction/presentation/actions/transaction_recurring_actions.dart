import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/recurrence_frequency.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';

class TransactionRecurringActions {
  const TransactionRecurringActions({
    required this.transaction,
    required this.recurringTemplate,
  });

  final TransactionEntity? transaction;
  final RecurringTransactionEntity? recurringTemplate;

  RecurringTransactionEntity? resolveTemplate(BuildContext context) {
    if (recurringTemplate != null) return recurringTemplate;
    final recurringTemplateUuid = transaction?.recurringTemplateUuid;
    if (recurringTemplateUuid == null) return null;

    return context
        .read<RecurringTransactionCubit>()
        .state
        .transactions
        .where((template) => template.uuid == recurringTemplateUuid)
        .firstOrNull;
  }

  Future<bool> handleRecurringEditIfNeeded({
    required BuildContext context,
    required bool isEditing,
    required TransactionEntity updatedTransaction,
  }) async {
    final template = resolveTemplate(context);
    if (!isEditing || template == null) return false;

    final scope = await _showEditScopeDialog(context);
    if (!context.mounted || scope == null) return true;

    _saveRecurringEdit(
      context: context,
      scope: scope,
      transaction: updatedTransaction,
      recurringTemplate: template,
    );
    return true;
  }

  Future<void> confirmDelete({
    required BuildContext context,
    required bool isEditing,
    required VoidCallback onRecurringDeleteStarted,
  }) async {
    final template = resolveTemplate(context);
    if (template != null) {
      await _showRecurringDeleteDialog(
        context,
        template,
        transactionUuid: isEditing ? transaction!.uuid : null,
        onRecurringDeleteStarted: onRecurringDeleteStarted,
      );
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: context.l10n.deleteTransaction,
      message: context.l10n.areYouSureDeleteTransaction,
      confirmText: context.l10n.delete,
      isDestructive: true,
    );

    if (confirmed == true) {
      sl<TransactionCubit>().removeTransaction(transaction!.uuid);
    }
  }

  Future<_RecurringEditScope?> _showEditScopeDialog(BuildContext context) {
    return showAppActionDialog<_RecurringEditScope>(
      context: context,
      title: context.l10n.editRepeatingTransaction,
      message: context.l10n.editRepeatingTransactionMessage,
      actions: [
        AppDialogAction<_RecurringEditScope>(
          text: context.l10n.cancel,
          value: null,
        ),
        AppDialogAction<_RecurringEditScope>(
          text: context.l10n.onlyThisTransaction,
          value: _RecurringEditScope.onlyThis,
        ),
        AppDialogAction<_RecurringEditScope>(
          text: context.l10n.futureTransactions,
          value: _RecurringEditScope.future,
        ),
        AppDialogAction<_RecurringEditScope>(
          text: context.l10n.entireSeries,
          value: _RecurringEditScope.entireSeries,
        ),
      ],
    );
  }

  void _saveRecurringEdit({
    required BuildContext context,
    required _RecurringEditScope scope,
    required TransactionEntity transaction,
    required RecurringTransactionEntity recurringTemplate,
  }) {
    final transactionCubit = context.read<TransactionCubit>();
    final recurringCubit = context.read<RecurringTransactionCubit>();

    switch (scope) {
      case _RecurringEditScope.onlyThis:
        transactionCubit.editTransaction(
          transaction.copyWith(clearRecurringTemplateUuid: true),
        );
      case _RecurringEditScope.future:
        final newTemplateUuid = const Uuid().v4();
        final previousEndDate = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day - 1,
        );
        recurringCubit.updateRecurringTransaction(
          recurringTemplate.copyWith(endDate: previousEndDate),
        );
        recurringCubit.addRecurringTransaction(
          _recurringTemplateFromTransaction(
            uuid: newTemplateUuid,
            transaction: transaction,
            frequency: recurringTemplate.frequency,
          ),
        );
        transactionCubit.editTransaction(
          transaction.copyWith(recurringTemplateUuid: newTemplateUuid),
        );
      case _RecurringEditScope.entireSeries:
        recurringCubit.updateRecurringTransaction(
          _recurringTemplateFromTransaction(
            uuid: recurringTemplate.uuid,
            transaction: transaction,
            frequency: recurringTemplate.frequency,
            startDate: recurringTemplate.startDate,
            endDate: recurringTemplate.endDate,
            createdDate: recurringTemplate.createdDate,
            isActive: recurringTemplate.isActive,
          ),
        );
        transactionCubit.editTransaction(transaction);
    }
  }

  RecurringTransactionEntity _recurringTemplateFromTransaction({
    required String uuid,
    required TransactionEntity transaction,
    required RecurrenceFrequency frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdDate,
    bool isActive = true,
  }) {
    return RecurringTransactionEntity(
      uuid: uuid,
      amount: transaction.amount,
      currency: transaction.currency,
      type: transaction.type,
      categoryUuid: transaction.categoryUuid,
      accountUuid: transaction.accountUuid,
      toAccountUuid: transaction.toAccountUuid,
      note: transaction.note,
      startDate: startDate ?? transaction.date,
      endDate: endDate,
      createdDate: createdDate ?? DateTime.now(),
      frequency: frequency,
      isActive: isActive,
    );
  }

  Future<void> _showRecurringDeleteDialog(
    BuildContext context,
    RecurringTransactionEntity recurringTemplate, {
    required VoidCallback onRecurringDeleteStarted,
    String? transactionUuid,
  }) async {
    final action = await showAppActionDialog<_RecurringDeleteAction>(
      context: context,
      title: context.l10n.repeatingTransaction,
      message: context.l10n.repeatingTransactionDeleteMessage,
      actions: [
        AppDialogAction<_RecurringDeleteAction>(
          text: context.l10n.cancel,
          value: null,
        ),
        AppDialogAction<_RecurringDeleteAction>(
          text: context.l10n.stopRepeat,
          value: _RecurringDeleteAction.stopRepeat,
        ),
        AppDialogAction<_RecurringDeleteAction>(
          text: context.l10n.deleteSeries,
          value: _RecurringDeleteAction.deleteSeries,
          isDestructive: true,
        ),
      ],
    );

    switch (action) {
      case _RecurringDeleteAction.stopRepeat:
        onRecurringDeleteStarted();
        sl<RecurringTransactionCubit>().updateRecurringTransaction(
          recurringTemplate.copyWith(isActive: false),
        );
      case _RecurringDeleteAction.deleteSeries:
        onRecurringDeleteStarted();
        sl<RecurringTransactionCubit>().removeRecurringTransaction(
          recurringTemplate.uuid,
        );
        final transactionCubit = sl<TransactionCubit>();
        final linkedTransactions = transactionCubit.state.transactions
            .where(
              (transaction) =>
                  transaction.recurringTemplateUuid == recurringTemplate.uuid ||
                  transaction.uuid == transactionUuid,
            )
            .toList();
        for (final transaction in linkedTransactions) {
          transactionCubit.removeTransaction(transaction.uuid);
        }
      case null:
        break;
    }
  }
}

enum _RecurringDeleteAction { stopRepeat, deleteSeries }

enum _RecurringEditScope { onlyThis, future, entireSeries }
