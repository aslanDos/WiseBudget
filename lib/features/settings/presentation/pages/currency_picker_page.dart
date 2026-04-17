import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_state.dart';

class CurrencyPickerPage extends StatelessWidget {
  const CurrencyPickerPage({super.key});

  static const _currencies = [
    _Currency('KZT', 'Kazakhstani Tenge', '₸'),
    _Currency('USD', 'US Dollar', '\$'),
    _Currency('EUR', 'Euro', '€'),
    _Currency('RUB', 'Russian Ruble', '₽'),
    _Currency('GBP', 'British Pound', '£'),
    _Currency('CNY', 'Chinese Yuan', '¥'),
    _Currency('JPY', 'Japanese Yen', '¥'),
    _Currency('AED', 'UAE Dirham', 'د.إ'),
    _Currency('TRY', 'Turkish Lira', '₺'),
    _Currency('KGS', 'Kyrgyzstani Som', 'с'),
    _Currency('UZS', 'Uzbekistani Som', 'сум'),
    _Currency('BYN', 'Belarusian Ruble', 'Br'),
    _Currency('CHF', 'Swiss Franc', 'Fr'),
    _Currency('CAD', 'Canadian Dollar', 'CA\$'),
    _Currency('AUD', 'Australian Dollar', 'A\$'),
    _Currency('INR', 'Indian Rupee', '₹'),
    _Currency('BRL', 'Brazilian Real', 'R\$'),
    _Currency('MXN', 'Mexican Peso', 'MX\$'),
    _Currency('SGD', 'Singapore Dollar', 'S\$'),
    _Currency('HKD', 'Hong Kong Dollar', 'HK\$'),
    _Currency('SEK', 'Swedish Krona', 'kr'),
    _Currency('NOK', 'Norwegian Krone', 'kr'),
    _Currency('DKK', 'Danish Krone', 'kr'),
    _Currency('PLN', 'Polish Zloty', 'zł'),
    _Currency('CZK', 'Czech Koruna', 'Kč'),
    _Currency('HUF', 'Hungarian Forint', 'Ft'),
    _Currency('RON', 'Romanian Leu', 'lei'),
    _Currency('ZAR', 'South African Rand', 'R'),
    _Currency('SAR', 'Saudi Riyal', '﷼'),
    _Currency('QAR', 'Qatari Riyal', '﷼'),
    _Currency('KWD', 'Kuwaiti Dinar', 'د.ك'),
    _Currency('EGP', 'Egyptian Pound', 'E£'),
    _Currency('NGN', 'Nigerian Naira', '₦'),
    _Currency('MYR', 'Malaysian Ringgit', 'RM'),
    _Currency('THB', 'Thai Baht', '฿'),
    _Currency('IDR', 'Indonesian Rupiah', 'Rp'),
    _Currency('PHP', 'Philippine Peso', '₱'),
    _Currency('PKR', 'Pakistani Rupee', '₨'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: const _CurrencyPickerView(),
    );
  }
}

class _CurrencyPickerView extends StatelessWidget {
  const _CurrencyPickerView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final selected = state.currency;

        final selectedCurrency = CurrencyPickerPage._currencies
            .where((c) => c.code == selected)
            .firstOrNull;
        final rest =
            CurrencyPickerPage._currencies
                .where((c) => c.code != selected)
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            centerTitle: false,
            title: Text(context.l10n.currency),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (selectedCurrency != null) ...[
                _buildCard(context, [selectedCurrency], selectedCode: selected),
                const SizedBox(height: 16),
              ],
              _buildCard(context, rest, selectedCode: selected),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    List<_Currency> currencies, {
    required String selectedCode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < currencies.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: context.c.onSurface.withAlpha(0x14),
              ),
            _CurrencyTile(
              currency: currencies[i],
              isSelected: currencies[i].code == selectedCode,
              isFirst: i == 0,
              isLast: i == currencies.length - 1,
              onTap: () => sl<SettingsCubit>().setCurrency(currencies[i].code),
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final _Currency currency;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _CurrencyTile({
    required this.currency,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                currency.symbol,
                style: context.t.bodyMedium?.copyWith(
                  color: context.c.onSurface.withAlpha(0x60),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.code,
                    style: context.t.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? context.c.primary
                          : context.c.onSurface,
                    ),
                  ),
                  Text(
                    currency.name,
                    style: context.t.bodySmall?.copyWith(
                      color: context.c.onSurface.withAlpha(0x60),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isSelected ? 1.0 : 0.0,
              child: Icon(
                Icons.check_rounded,
                size: 20,
                color: context.c.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Currency {
  final String code;
  final String name;
  final String symbol;

  const _Currency(this.code, this.name, this.symbol);
}
