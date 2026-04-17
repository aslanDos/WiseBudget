import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final Locale? locale;
  final ThemeMode themeMode;
  final String currency;
  final String launchPage;

  const SettingsState({
    this.locale,
    this.themeMode = ThemeMode.system,
    this.currency = 'KZT',
    this.launchPage = 'home',
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    String? currency,
    String? launchPage,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      launchPage: launchPage ?? this.launchPage,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode, currency, launchPage];
}
