import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Returns true if the device is a tablet (based on shortest side > 600).
bool _isTablet(BuildContext context) {
  final shortestSide = MediaQuery.of(context).size.shortestSide;
  return shortestSide > 600;
}

/// Shows a modal bottom sheet with platform-adaptive styling.
///
/// On iOS/macOS: Uses Cupertino-style modal with stretchy physics.
/// On Android/others: Uses Material-style modal.
/// On tablets: Shows as a centered dialog-style modal.
Future<T?> showModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useSafeArea = true,
  bool expand = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  if (_isTablet(context)) {
    // On tablets, show as a dialog-style modal
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: builder(context),
          ),
        ),
      ),
    );
  }

  // Use standard modal bottom sheet (no push-back scaling effect)
  // This works better for nested modals within other modals
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: expand,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
    ),
  );
}

class ModalSheet extends StatelessWidget {
  final Widget? title;
  final Widget? child;
  final Widget? leading;
  final Widget? trailing;

  final double leadingSpacing;
  final double trailingSpacing;

  /// Defaults to `40.0`
  ///
  /// Set this to `0.0` to make bottom sheet contact with the system navigation bar.
  /// This has no effect when [scrollable] is `false`.
  final double topMargin;
  final double titleSpacing;

  final bool scrollable;
  final bool showDragHandle;

  /// Minimum height for scrollable content.
  /// Defaults to `64.0`.
  final double minScrollableContentHeight;
  final double scrollableContentMaxHeight;

  const ModalSheet({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.trailing,
    this.topMargin = 40.0,
    this.titleSpacing = 16.0,
    this.leadingSpacing = 16.0,
    this.trailingSpacing = 8.0,
    this.showDragHandle = false,
  }) : scrollable = false,
       scrollableContentMaxHeight = 0,
       minScrollableContentHeight = 0;

  /// Creates a scrollable modal sheet.
  ///
  /// [scrollableContentMaxHeight] defaults to 50% of the screen height.
  /// Setting it to `0.0` will use the default behaviour.
  const ModalSheet.scrollable({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.trailing,
    this.minScrollableContentHeight = 64.0,
    this.topMargin = 40.0,
    this.titleSpacing = 16.0,
    this.leadingSpacing = 16.0,
    this.trailingSpacing = 8.0,
    this.scrollableContentMaxHeight = 0.0,
  }) : scrollable = true,
       showDragHandle = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isTablet = _isTablet(context);

    final Widget? titleWidget = title == null
        ? null
        : DefaultTextStyle(
            style: textTheme.headlineSmall!,
            textAlign: TextAlign.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: title!,
            ),
          );

    // On tablets (dialog mode), don't show drag handle
    final shouldShowDragHandle = showDragHandle && !isTablet;

    return Material(
      color: colorScheme.surface,
      borderRadius: isTablet
          ? BorderRadius.circular(24.0)
          : const BorderRadius.vertical(top: Radius.circular(24.0)),
      child: Container(
        padding: MediaQuery.of(context).viewInsets,
        constraints: BoxConstraints.loose(
          Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height - topMargin,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (shouldShowDragHandle)
                Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  width: 36.0,
                  height: 5.0,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withAlpha(0x4D),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              SizedBox(height: titleSpacing),
              ?titleWidget,
              if (titleWidget != null && (leading != null || child != null))
                SizedBox(height: titleSpacing),
              if (leading != null) ...[
                leading!,
                SizedBox(height: leadingSpacing),
              ],
              if (child != null)
                Flexible(
                  child: Builder(builder: (context) => _buildContent(context)),
                ),
              if (trailing != null) ...[
                SizedBox(height: trailingSpacing),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!scrollable) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: child,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxScrollableContentHeight = math.max(
          MediaQuery.of(context).size.height -
              64.0 -
              MediaQuery.viewInsetsOf(context).bottom,
          scrollableContentMaxHeight,
        );

        return AnimatedContainer(
          constraints: BoxConstraints.loose(
            Size(
              double.infinity,
              math.min(
                    math.max(
                      minScrollableContentHeight,
                      maxScrollableContentHeight,
                    ),
                    constraints.maxHeight,
                  ) -
                  64.0,
            ),
          ),
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
    );
  }
}

/// Shows a modal input sheet with a text field and send button.
///
/// Returns the entered text when saved, or null if dismissed.
///
/// The keyboard opens immediately when the modal appears.
Future<String?> showModalInput({
  required BuildContext context,
  String? initialValue,
  String? hintText,
  int? maxLength,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  final controller = TextEditingController(text: initialValue);
  final focusNode = FocusNode();
  final colorScheme = Theme.of(context).colorScheme;

  Widget buildSheet(BuildContext context) {
    // Request focus after the modal is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    return _ModalInputSheet(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      maxLength: maxLength,
    );
  }

  Future<String?> result;

  if (_isTablet(context)) {
    result = showDialog<String>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: buildSheet(context),
        ),
      ),
    );
  } else {
    // Use standard modal bottom sheet (no push-back scaling effect)
    result = showModalBottomSheet<String>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: buildSheet,
    );
  }

  return result.whenComplete(() {
    focusNode.dispose();
    controller.dispose();
  });
}

class _ModalInputSheet extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final int? maxLength;

  const _ModalInputSheet({
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = _isTablet(context);

    return Material(
      color: colorScheme.surface,
      borderRadius: isTablet
          ? BorderRadius.circular(24.0)
          : const BorderRadius.vertical(top: Radius.circular(24.0)),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle (only on phones)
              if (!isTablet)
                Container(
                  margin: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                  width: 36.0,
                  height: 5.0,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withAlpha(0x4D),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              if (isTablet) const SizedBox(height: 16.0),
              // Input row
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Row(
                  children: [
                    // TextField
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          maxLength: maxLength,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: hintText ?? 'Enter text...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 14.0,
                            ),
                            counterText: '',
                          ),
                          onSubmitted: (value) {
                            Navigator.pop(context, value.trim());
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Send button
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context, controller.text.trim());
                        },
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
