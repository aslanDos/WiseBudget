import 'package:flutter/material.dart';
import 'package:wisebuget/core/l10n/l10n.dart';

class CubitErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const CubitErrorWidget({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(
            message ?? context.l10n.somethingWentWrong,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}
