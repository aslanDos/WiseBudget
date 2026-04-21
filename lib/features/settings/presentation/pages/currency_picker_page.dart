import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/settings/presentation/cubit/currency_rates_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<SettingsCubit>()),
        BlocProvider(
          create: (_) => CurrencyRatesCubit(networkService: sl()),
        ),
      ],
      child: const _CurrencyPickerView(),
    );
  }
}

class _CurrencyPickerView extends StatelessWidget {
  const _CurrencyPickerView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final selected = settingsState.currency;

        // Trigger rate fetch whenever selected currency changes.
        context.read<CurrencyRatesCubit>().loadRates(selected);

        final selectedCurrency = CurrencyPickerPage._currencies
            .where((c) => c.code == selected)
            .firstOrNull;
        final rest = CurrencyPickerPage._currencies
            .where((c) => c.code != selected)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            centerTitle: false,
            title: Text(context.l10n.currency),
            actions: [
              BlocBuilder<CurrencyRatesCubit, CurrencyRatesState>(
                builder: (context, ratesState) {
                  if (ratesState.status == CubitStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  if (ratesState.status == CubitStatus.failure) {
                    return IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => context
                          .read<CurrencyRatesCubit>()
                          .loadRates(selected),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<CurrencyRatesCubit, CurrencyRatesState>(
            builder: (context, ratesState) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (ratesState.status == CubitStatus.success &&
                      ratesState.lastUpdated != null)
                    _RatesInfoBanner(lastUpdated: ratesState.lastUpdated!),
                  if (ratesState.status == CubitStatus.failure)
                    const _RatesErrorBanner(),
                  if (ratesState.status != CubitStatus.initial)
                    const SizedBox(height: 16),
                  if (selectedCurrency != null) ...[
                    _buildCard(
                      context,
                      [selectedCurrency],
                      selectedCode: selected,
                      ratesState: ratesState,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildCard(
                    context,
                    rest,
                    selectedCode: selected,
                    ratesState: ratesState,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    List<_Currency> currencies, {
    required String selectedCode,
    required CurrencyRatesState ratesState,
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
              rateInBase: ratesState.rateFor(currencies[i].code),
              baseCode: ratesState.baseCurrency,
              ratesLoaded: ratesState.status == CubitStatus.success,
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
  final double? rateInBase;
  final String baseCode;
  final bool ratesLoaded;
  final VoidCallback onTap;

  const _CurrencyTile({
    required this.currency,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.rateInBase,
    required this.baseCode,
    required this.ratesLoaded,
    required this.onTap,
  });

  String _formatRate(double rate) {
    if (rate >= 10000) return rate.toStringAsFixed(0);
    if (rate >= 100) return rate.toStringAsFixed(1);
    if (rate >= 1) return rate.toStringAsFixed(2);
    if (rate >= 0.01) return rate.toStringAsFixed(4);
    return rate.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    final rateLabel = isSelected
        ? '1 ${currency.code} = 1 $baseCode'
        : rateInBase != null
        ? '1 ${currency.code} ≈ ${_formatRate(rateInBase!)} $baseCode'
        : ratesLoaded
        ? null  // loaded but no rate for this pair
        : null; // still loading

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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isSelected ? context.c.primary : context.c.onSurface,
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
            if (rateLabel != null) ...[
              const SizedBox(width: 8),
              Text(
                rateLabel,
                style: context.t.bodySmall?.copyWith(
                  color: isSelected
                      ? context.c.primary.withAlpha(0xCC)
                      : context.c.onSurface.withAlpha(0x80),
                ),
              ),
              const SizedBox(width: 8),
            ],
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

class _RatesInfoBanner extends StatelessWidget {
  const _RatesInfoBanner({required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final local = lastUpdated.toLocal();
    final formatted = DateFormat('dd MMM yyyy, HH:mm').format(local);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.c.primary.withAlpha(0x18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: context.c.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rates updated $formatted · open.er-api.com',
              style: context.t.bodySmall?.copyWith(color: context.c.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatesErrorBanner extends StatelessWidget {
  const _RatesErrorBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.c.error.withAlpha(0x18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: context.c.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Could not load live rates. Tap refresh to retry.',
              style: context.t.bodySmall?.copyWith(color: context.c.error),
            ),
          ),
        ],
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
