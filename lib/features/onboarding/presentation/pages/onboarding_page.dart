import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/onboarding/presentation/widgets/onboarding_content.dart';
import 'package:wisebuget/features/onboarding/presentation/widgets/page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Account form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  String _selectedCurrency = 'KZT';

  static const _currencies = ['KZT', 'USD', 'EUR', 'RUB'];

  List<({IconData icon, String title, String description})> _onboardingData(AppLocalizations l10n) => [
    (icon: LucideIcons.wallet, title: l10n.welcomeToWiseBudget, description: l10n.onboardingDescription1),
    (icon: LucideIcons.arrowLeftRight, title: l10n.trackEveryTransaction, description: l10n.onboardingDescription2),
    (icon: LucideIcons.chartPie, title: l10n.gainFinancialInsights, description: l10n.onboardingDescription3),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _skipToAccountCreation() {
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _createAccount(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = sl<AccountCubit>();
    final newAccount = AccountEntity(
      uuid: const Uuid().v4(),
      name: _nameController.text.trim(),
      currency: _selectedCurrency,
      balance: double.tryParse(_balanceController.text) ?? 0,
      iconCode: 'wallet',
      createdDate: DateTime.now(),
      colorValue: AppPalette.defaultAccountColor,
    );

    cubit.addAccount(newAccount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AccountCubit>(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Skip button (pages 0-2)
              Align(
                alignment: Alignment.topRight,
                child: AnimatedOpacity(
                  opacity: _currentPage < 3 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _currentPage < 3
                          ? _skipToAccountCreation
                          : null,
                      child: Text(context.l10n.skip),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    // Intro pages (0-2)
                    ...List.generate(
                      _onboardingData(context.l10n).length,
                      (index) => OnboardingContent(
                        icon: _onboardingData(context.l10n)[index].icon,
                        title: _onboardingData(context.l10n)[index].title,
                        description: _onboardingData(context.l10n)[index].description,
                        isActive: _currentPage == index,
                      ),
                    ),
                    // Account creation page (3)
                    _AccountCreationPage(
                      formKey: _formKey,
                      nameController: _nameController,
                      balanceController: _balanceController,
                      selectedCurrency: _selectedCurrency,
                      currencies: _currencies,
                      onCurrencyChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCurrency = value);
                        }
                      },
                      onCreateAccount: () => _createAccount(context),
                    ),
                  ],
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: PageIndicator(pageCount: 4, currentPage: _currentPage),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                child: _currentPage < 3
                    ? SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _nextPage,
                          child: Text(
                            _currentPage == 2 ? context.l10n.getStarted : context.l10n.next,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCreationPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController balanceController;
  final String selectedCurrency;
  final List<String> currencies;
  final ValueChanged<String?> onCurrencyChanged;
  final VoidCallback onCreateAccount;

  const _AccountCreationPage({
    required this.formKey,
    required this.nameController,
    required this.balanceController,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencyChanged,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24.0),

            // Header
            Text(
              l10n.createFirstAccount,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              l10n.setUpAccountDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),

            // Account name field
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.accountNameLabel,
                hintText: l10n.cashSavingsExample,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterAccountName;
                }
                if (value.length > 50) {
                  return l10n.nameTooLong;
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Currency dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedCurrency,
              decoration: InputDecoration(
                labelText: l10n.currency,
                border: const OutlineInputBorder(),
              ),
              items: currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: onCurrencyChanged,
            ),
            const SizedBox(height: 16.0),

            // Initial balance field
            TextFormField(
              controller: balanceController,
              decoration: InputDecoration(
                labelText: l10n.initialBalance,
                hintText: '0.00',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return l10n.pleaseEnterValidNumber;
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32.0),

            // Create account button with listener
            BlocConsumer<AccountCubit, AccountState>(
              listenWhen: (previous, current) =>
                  previous.status == CubitStatus.loading &&
                  current.status != CubitStatus.loading,
              listener: (context, state) async {
                if (state.status == CubitStatus.success) {
                  await sl<LocalPreferences>().setCompletedOnboarding(true);
                  if (context.mounted) {
                    context.go(AppRoutes.home);
                  }
                } else if (state.status == CubitStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage ?? context.l10n.failedToCreateAccount,
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state.status == CubitStatus.loading;
                return FilledButton(
                  onPressed: isLoading ? null : onCreateAccount,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.l10n.createAccount),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
