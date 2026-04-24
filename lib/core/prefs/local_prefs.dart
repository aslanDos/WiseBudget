// ignore_for_file: public_member_api_docs, sort_constructors_first
import "package:shared_preferences/shared_preferences.dart";
import "package:wisebuget/core/prefs/local_prefs_constants.dart";

class LocalPreferences {
  final SharedPreferences _prefs;

  LocalPreferences({required SharedPreferences prefs}) : _prefs = prefs;

  /// onboarding
  bool get completedOnboarding =>
      _prefs.getBool(PrefsConstants.completedOnboardingKey) ?? false;

  Future<void> setCompletedOnboarding(bool value) =>
      _prefs.setBool(PrefsConstants.completedOnboardingKey, value);

  /// theme
  String get themeMode =>
      _prefs.getString(PrefsConstants.themeModeKey) ?? "system";

  Future<void> setThemeMode(String value) =>
      _prefs.setString(PrefsConstants.themeModeKey, value);

  /// locale
  String? get locale => _prefs.getString(PrefsConstants.localeKey);

  Future<void> setLocale(String value) =>
      _prefs.setString(PrefsConstants.localeKey, value);

  /// currency
  String get currency => _prefs.getString(PrefsConstants.currencyKey) ?? "KZT";

  Future<void> setCurrency(String value) =>
      _prefs.setString(PrefsConstants.currencyKey, value);

  /// launch page
  String get launchPage =>
      _prefs.getString(PrefsConstants.launchPageKey) ?? 'home';

  Future<void> setLaunchPage(String value) =>
      _prefs.setString(PrefsConstants.launchPageKey, value);

  /// last chosen account
  String? get lastChosenAccount =>
      _prefs.getString(PrefsConstants.lastChosenAccountKey);

  Future<void> setLastChosenAccount(String? value) async {
    if (value == null) {
      await _prefs.remove(PrefsConstants.lastChosenAccountKey);
    } else {
      await _prefs.setString(PrefsConstants.lastChosenAccountKey, value);
    }
  }

  /// analytics period
  String? get analyticsPeriod =>
      _prefs.getString(PrefsConstants.analyticsPeriodKey);

  Future<void> setAnalyticsPeriod(String value) =>
      _prefs.setString(PrefsConstants.analyticsPeriodKey, value);

  /// analytics account
  String? get analyticsAccount =>
      _prefs.getString(PrefsConstants.analyticsAccountKey);

  Future<void> setAnalyticsAccount(String? value) async {
    if (value == null) {
      await _prefs.remove(PrefsConstants.analyticsAccountKey);
    } else {
      await _prefs.setString(PrefsConstants.analyticsAccountKey, value);
    }
  }

  /// analytics category type
  String? get analyticsCategoryType =>
      _prefs.getString(PrefsConstants.analyticsCategoryTypeKey);

  Future<void> setAnalyticsCategoryType(String value) =>
      _prefs.setString(PrefsConstants.analyticsCategoryTypeKey, value);
}
