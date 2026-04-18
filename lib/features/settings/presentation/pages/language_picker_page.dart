import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_state.dart';

class LanguagePickerPage extends StatelessWidget {
  const LanguagePickerPage({super.key});

  static const _languages = [
    _Language(code: 'en', nativeName: 'English'),
    _Language(code: 'kk', nativeName: 'Қазақша'),
    _Language(code: 'ru', nativeName: 'Русский'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final selectedCode = state.locale?.languageCode ?? 'en';

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 16,
              centerTitle: false,
              title: Text(context.l10n.language),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: context.c.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < _languages.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: context.c.onSurface.withAlpha(0x14),
                          ),
                        _PickerTile(
                          label: _languages[i].nativeName,
                          isSelected: selectedCode == _languages[i].code,
                          isFirst: i == 0,
                          isLast: i == _languages.length - 1,
                          onTap: () => sl<SettingsCubit>().setLocale(
                            Locale(_languages[i].code),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Language {
  final String code;
  final String nativeName;

  const _Language({required this.code, required this.nativeName});
}

class _PickerTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
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
            Expanded(
              child: Text(
                label,
                style: context.t.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? context.c.primary : context.c.onSurface,
                ),
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
