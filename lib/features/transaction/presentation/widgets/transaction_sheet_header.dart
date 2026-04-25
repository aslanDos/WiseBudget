import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/account_chip.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/transaction/domain/recurrence_frequency.dart';

class TransactionSheetHeader extends StatefulWidget {
  final bool isEditing;
  final String? selectedAccountUuid;
  final bool isRecurringEnabled;
  final RecurrenceFrequency recurrenceFrequency;
  final ValueChanged<String> onAccountSelected;
  final ValueChanged<RecurrenceFrequency?> onRecurrenceChanged;
  final VoidCallback onDelete;

  const TransactionSheetHeader({
    super.key,
    required this.isEditing,
    required this.selectedAccountUuid,
    required this.isRecurringEnabled,
    required this.recurrenceFrequency,
    required this.onAccountSelected,
    required this.onRecurrenceChanged,
    required this.onDelete,
  });

  @override
  State<TransactionSheetHeader> createState() => _TransactionSheetHeaderState();
}

class _TransactionSheetHeaderState extends State<TransactionSheetHeader> {
  final GlobalKey _menuButtonKey = GlobalKey();

  Rect? get _menuButtonRect {
    final context = _menuButtonKey.currentContext;
    final box = context?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;

    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  Future<void> _showRepeatMenu() async {
    final position = _menuButtonRect;
    if (position == null) return;

    await showPullDownMenu(
      context: context,
      position: position,
      items: [
        _LeadingPullDownMenuItem(
          title: context.l10n.repeat,
          icon: AppIcons.repeat,
          onTap: null,
          enabled: false,
        ),
        PullDownMenuItem.selectable(
          selected: !widget.isRecurringEnabled,
          title: context.l10n.never,
          onTap: () => widget.onRecurrenceChanged(null),
        ),
        ...RecurrenceFrequency.values.map(
          (frequency) => PullDownMenuItem.selectable(
            selected:
                widget.isRecurringEnabled &&
                widget.recurrenceFrequency == frequency,
            title: frequency.label,
            onTap: () => widget.onRecurrenceChanged(frequency),
          ),
        ),
      ],
    );
  }

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
                        .where((a) => a.uuid == widget.selectedAccountUuid)
                        .firstOrNull;

                    return AccountChip(
                      backgroundColor: Colors.transparent,
                      account: account,
                      accounts: state.accounts,
                      onSelected: widget.onAccountSelected,
                    );
                  },
                ),
              ),
            ),
            PullDownButton(
              itemBuilder: (context) => [
                _LeadingPullDownMenuItem(
                  title: context.l10n.repeat,
                  icon: AppIcons.repeat,
                  onTap: _showRepeatMenu,
                ),
                if (widget.isEditing)
                  _LeadingPullDownMenuItem(
                    title: context.l10n.delete,
                    icon: AppIcons.trash,
                    isDestructive: true,
                    onTap: widget.onDelete,
                  ),
              ],
              buttonBuilder: (context, showMenu) => SizedBox(
                key: _menuButtonKey,
                child: ActionButton(
                  backgroundColor: Colors.transparent,
                  icon: AppIcons.elipsesVertical,
                  onTap: showMenu,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingPullDownMenuItem extends StatefulWidget
    implements PullDownMenuEntry {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool enabled;

  const _LeadingPullDownMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.enabled = true,
  });

  @override
  State<_LeadingPullDownMenuItem> createState() =>
      _LeadingPullDownMenuItemState();
}

class _LeadingPullDownMenuItemState extends State<_LeadingPullDownMenuItem> {
  var _isHovered = false;
  var _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final itemTheme = PullDownMenuItemTheme.maybeOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle =
        itemTheme?.textStyle ?? Theme.of(context).textTheme.bodyMedium!;
    final foregroundColor = widget.isDestructive
        ? itemTheme?.destructiveColor ?? colorScheme.error
        : textStyle.color ?? colorScheme.onSurface;
    final disabledOpacity = Theme.of(context).brightness == Brightness.dark
        ? 0.55
        : 0.45;
    final resolvedForegroundColor = widget.enabled
        ? foregroundColor
        : foregroundColor.withValues(alpha: disabledOpacity);
    final backgroundColor = !widget.enabled
        ? Colors.transparent
        : _isPressed
        ? itemTheme?.onPressedBackgroundColor ?? colorScheme.surfaceContainer
        : _isHovered
        ? itemTheme?.onHoverBackgroundColor ?? colorScheme.surfaceContainer
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) {
        if (widget.enabled) setState(() => _isHovered = true);
      },
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: Listener(
        onPointerDown: (_) {
          if (widget.enabled) setState(() => _isPressed = true);
        },
        onPointerUp: (_) {
          if (widget.enabled) setState(() => _isPressed = false);
        },
        onPointerCancel: (_) {
          if (widget.enabled) setState(() => _isPressed = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled
              ? () => PullDownMenuItem.defaultTapHandler(context, widget.onTap)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            color: backgroundColor,
            child: Row(
              children: [
                Icon(widget.icon, size: 18, color: resolvedForegroundColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(color: resolvedForegroundColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
