import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDialogAction<T> {
  final String text;
  final T? value;
  final bool isDestructive;
  final bool isDefault;

  const AppDialogAction({
    required this.text,
    required this.value,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

  if (isIOS) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  final colorScheme = Theme.of(context).colorScheme;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? colorScheme.error : null,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

Future<T?> showAppActionDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required List<AppDialogAction<T>> actions,
}) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

  if (isIOS) {
    return showCupertinoDialog<T>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions
            .map(
              (action) => CupertinoDialogAction(
                isDefaultAction: action.isDefault,
                isDestructiveAction: action.isDestructive,
                onPressed: () => Navigator.pop(context, action.value),
                child: Text(action.text),
              ),
            )
            .toList(),
      ),
    );
  }

  final colorScheme = Theme.of(context).colorScheme;

  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: actions
          .map(
            (action) => TextButton(
              style: TextButton.styleFrom(
                foregroundColor: action.isDestructive
                    ? colorScheme.error
                    : null,
              ),
              onPressed: () => Navigator.pop(context, action.value),
              child: Text(action.text),
            ),
          )
          .toList(),
    ),
  );
}
