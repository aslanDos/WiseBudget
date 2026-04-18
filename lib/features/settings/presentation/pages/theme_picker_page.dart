import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_state.dart';

class ThemePickerPage extends StatelessWidget {
  const ThemePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final options = [
            _ThemeOption(ThemeMode.system, l10n.themeSystem),
            _ThemeOption(ThemeMode.light, l10n.themeLight),
            _ThemeOption(ThemeMode.dark, l10n.themeDark),
          ];

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 16,
              centerTitle: false,
              title: Text(l10n.theme),
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
                      for (int i = 0; i < options.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: context.c.onSurface.withAlpha(0x14),
                          ),
                        _PickerTile(
                          label: options[i].label,
                          isSelected: state.themeMode == options[i].mode,
                          isFirst: i == 0,
                          isLast: i == options.length - 1,
                          onTap: () =>
                              sl<SettingsCubit>().setThemeMode(options[i].mode),
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

class _ThemeOption {
  final ThemeMode mode;
  final String label;

  const _ThemeOption(this.mode, this.label);
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
