import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class AmountDisplay extends StatelessWidget {
  final String amount;
  final TransactionType type;

  const AmountDisplay({super.key, required this.amount, required this.type});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(amount),
        tween: Tween<double>(begin: 1.15, end: 1.0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Text(
          '$amount ₸',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.t.headlineLarge?.copyWith(color: type.backgroundColor),
        ),
      ),
    );
  }
}
