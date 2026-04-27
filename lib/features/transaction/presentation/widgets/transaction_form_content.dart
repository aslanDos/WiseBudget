import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/core/shared/layout/app_breakpoints.dart';
import 'package:wisebuget/core/shared/widgets/numpad.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_form_entity.dart';
import 'package:wisebuget/features/transaction/domain/recurrence_frequency.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/amount_display.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/rate_chip.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_details.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_sheet_header.dart';

class TransactionFormContent extends StatelessWidget {
  const TransactionFormContent({
    super.key,
    required this.form,
    required this.amountString,
    required this.canDelete,
    required this.rateChipLabel,
    required this.rateIsStale,
    required this.saveButton,
    required this.onAccountSelected,
    required this.onRecurrenceChanged,
    required this.onDelete,
    required this.onTypeChanged,
    required this.onCategorySelected,
    required this.onToAccountSelected,
    required this.onDateSelected,
    required this.onNoteChanged,
    required this.onNumpadKey,
    required this.onBackspace,
    required this.onClear,
  });

  final TransactionFormEntity form;
  final String amountString;
  final bool canDelete;
  final String? rateChipLabel;
  final bool rateIsStale;
  final Widget saveButton;
  final ValueChanged<String?> onAccountSelected;
  final ValueChanged<RecurrenceFrequency?> onRecurrenceChanged;
  final VoidCallback onDelete;
  final ValueChanged<TransactionType> onTypeChanged;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String?> onToAccountSelected;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<String> onNumpadKey;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.formWide;
        final horizontalPadding =
            constraints.maxWidth >= AppBreakpoints.comfortablePadding
            ? 24.0
            : 16.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 1080 : 760),
            child: Column(
              children: [
                TransactionSheetHeader(
                  isEditing: canDelete,
                  selectedAccountUuid: form.accountUuid,
                  isRecurringEnabled: form.isRecurring,
                  recurrenceFrequency: form.recurrenceFrequency,
                  onAccountSelected: onAccountSelected,
                  onRecurrenceChanged: onRecurrenceChanged,
                  onDelete: onDelete,
                ),
                if (!form.isAdjustment)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 18,
                    ),
                    child: _TransactionTypeToggle(
                      selected: form.type,
                      onChanged: onTypeChanged,
                    ),
                  ),
                Expanded(
                  child: isWide
                      ? _WideLayout(
                          horizontalPadding: horizontalPadding,
                          amountSection: _buildAmountSection(),
                          detailsPanel: _buildDetailsPanel(
                            context: context,
                            horizontalPadding: horizontalPadding,
                            roundedTopOnly: false,
                            includeNumpad: false,
                            includeBottomInset: false,
                            fillHeight: true,
                          ),
                          numpad: _buildNumpadCard(context),
                        )
                      : _CompactLayout(
                          amountSection: _buildAmountSection(),
                          detailsPanel: _buildDetailsPanel(
                            context: context,
                            horizontalPadding: horizontalPadding,
                            roundedTopOnly: true,
                            includeNumpad: true,
                            includeBottomInset: true,
                            fillHeight: false,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, accountState) {
              final account = accountState.accounts
                  .where((a) => a.uuid == form.accountUuid)
                  .firstOrNull;
              final currency =
                  account?.currency ?? sl<LocalPreferences>().currency;

              return AmountDisplay(
                amount: amountString.isEmpty ? '0' : amountString,
                type: form.type,
                currency: currency,
              );
            },
          ),
        ),
        if (rateChipLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RateChip(label: rateChipLabel!, isStale: rateIsStale),
          ),
      ],
    );
  }

  Widget _buildDetailsPanel({
    required BuildContext context,
    required double horizontalPadding,
    required bool roundedTopOnly,
    required bool includeNumpad,
    required bool includeBottomInset,
    required bool fillHeight,
  }) {
    final borderRadius = roundedTopOnly
        ? const BorderRadius.only(
            topRight: Radius.circular(24),
            topLeft: Radius.circular(24),
          )
        : BorderRadius.circular(24);

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        16,
      ),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (fillHeight)
            Expanded(
              child: SingleChildScrollView(
                child: _buildTransactionFields(includeNumpad: includeNumpad),
              ),
            )
          else
            SingleChildScrollView(
              child: _buildTransactionFields(includeNumpad: includeNumpad),
            ),
          const SizedBox(height: 8),
          saveButton,
          if (includeBottomInset)
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }

  Widget _buildTransactionFields({required bool includeNumpad}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<AccountCubit, AccountState>(
          builder: (context, accountState) {
            final availableToAccounts = form.filterToAccounts(
              accountState.accounts,
            );

            return BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                return TransactionDetails(
                  type: form.type,
                  date: form.date,
                  note: form.note,
                  selectedCategory: form.findSelectedCategory(
                    categoryState.categories,
                  ),
                  categories: form.filterCategories(categoryState.categories),
                  onCategorySelected: onCategorySelected,
                  selectedToAccount: form.findSelectedToAccount(
                    accountState.accounts,
                  ),
                  availableToAccounts: availableToAccounts,
                  onToAccountSelected: onToAccountSelected,
                  onDateSelected: onDateSelected,
                  onNoteChanged: onNoteChanged,
                );
              },
            );
          },
        ),
        if (includeNumpad) ...[const SizedBox(height: 8), _buildNumpad()],
      ],
    );
  }

  Widget _buildNumpadCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: _buildNumpad(),
    );
  }

  Widget _buildNumpad() {
    return Numpad(
      onKeyPressed: onNumpadKey,
      onBackspace: onBackspace,
      onClear: onClear,
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.amountSection,
    required this.detailsPanel,
  });

  final Widget amountSection;
  final Widget detailsPanel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: amountSection),
        detailsPanel,
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.horizontalPadding,
    required this.amountSection,
    required this.detailsPanel,
    required this.numpad,
  });

  final double horizontalPadding;
  final Widget amountSection;
  final Widget detailsPanel;
  final Widget numpad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: amountSection),
                const SizedBox(height: 16),
                numpad,
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(flex: 6, child: detailsPanel),
        ],
      ),
    );
  }
}

class _TransactionTypeToggle extends StatelessWidget {
  const _TransactionTypeToggle({
    required this.selected,
    required this.onChanged,
  });

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return TypeToggle<TransactionType>(
      items: TransactionType.values
          .where((t) => t != TransactionType.adjustment)
          .map(
            (t) => TypeToggleItem(
              value: t,
              label: t.label,
              icon: t.icon,
              selectedBackgroundColor: t.backgroundColor,
              selectedForegroundColor: t.backgroundColor,
            ),
          )
          .toList(),
      selected: selected,
      onChanged: onChanged,
    );
  }
}
