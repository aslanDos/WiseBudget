import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/usecases/clear_all_data.dart';
import 'package:wisebuget/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final LocalPreferences _prefs;
  final ClearAllData _clearAllData;

  SettingsCubit(this._prefs, this._clearAllData) : super(_initialState(_prefs));

  static SettingsState _initialState(LocalPreferences prefs) {
    final code = prefs.locale;
    return SettingsState(
      locale: code != null ? Locale(code) : null,
      themeMode: _parseThemeMode(prefs.themeMode),
      currency: prefs.currency,
      launchPage: prefs.launchPage,
    );
  }

  static ThemeMode _parseThemeMode(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setLocale(Locale locale) async {
    await _prefs.setLocale(locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setThemeMode(str);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setCurrency(String currency) async {
    await _prefs.setCurrency(currency);
    emit(state.copyWith(currency: currency));
  }

  Future<void> setLaunchPage(String page) async {
    await _prefs.setLaunchPage(page);
    emit(state.copyWith(launchPage: page));
  }

  Future<void> clearAllData() => _clearAllData();
}
