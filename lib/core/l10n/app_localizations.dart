import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'WiseBudget'**
  String get appName;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAndSchedule.
  ///
  /// In en, this message translates to:
  /// **'Save & schedule'**
  String get saveAndSchedule;

  /// No description provided for @saveRecurring.
  ///
  /// In en, this message translates to:
  /// **'Save recurring'**
  String get saveRecurring;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @repeatingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Repeating transaction'**
  String get repeatingTransaction;

  /// No description provided for @repeatingTransactionDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do with this repeat rule?'**
  String get repeatingTransactionDeleteMessage;

  /// No description provided for @stopRepeat.
  ///
  /// In en, this message translates to:
  /// **'Stop repeat'**
  String get stopRepeat;

  /// No description provided for @deleteSeries.
  ///
  /// In en, this message translates to:
  /// **'Delete series'**
  String get deleteSeries;

  /// No description provided for @editRepeatingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit repeating transaction'**
  String get editRepeatingTransaction;

  /// No description provided for @editRepeatingTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Apply these changes to this transaction, future transactions, or the entire series?'**
  String get editRepeatingTransactionMessage;

  /// No description provided for @onlyThisTransaction.
  ///
  /// In en, this message translates to:
  /// **'Only this transaction'**
  String get onlyThisTransaction;

  /// No description provided for @futureTransactions.
  ///
  /// In en, this message translates to:
  /// **'Future transactions'**
  String get futureTransactions;

  /// No description provided for @entireSeries.
  ///
  /// In en, this message translates to:
  /// **'Entire series'**
  String get entireSeries;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountName;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @allAccounts.
  ///
  /// In en, this message translates to:
  /// **'All Accounts'**
  String get allAccounts;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createFirstAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your First Account'**
  String get createFirstAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @trackSpendingAcrossAllAccounts.
  ///
  /// In en, this message translates to:
  /// **'Track spending across all accounts'**
  String get trackSpendingAcrossAllAccounts;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @selectCategories.
  ///
  /// In en, this message translates to:
  /// **'Select Categories'**
  String get selectCategories;

  /// No description provided for @selectAccounts.
  ///
  /// In en, this message translates to:
  /// **'Select Accounts'**
  String get selectAccounts;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @incomeAndExpenses.
  ///
  /// In en, this message translates to:
  /// **'Income and Expenses'**
  String get incomeAndExpenses;

  /// No description provided for @noExpenseData.
  ///
  /// In en, this message translates to:
  /// **'No expense data for this period'**
  String get noExpenseData;

  /// No description provided for @noIncomeData.
  ///
  /// In en, this message translates to:
  /// **'No income data for this period'**
  String get noIncomeData;

  /// No description provided for @addTransactionsToSeeOverview.
  ///
  /// In en, this message translates to:
  /// **'Add transactions to see your monthly overview'**
  String get addTransactionsToSeeOverview;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @yourBudgets.
  ///
  /// In en, this message translates to:
  /// **'Your Budgets'**
  String get yourBudgets;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @budgetName.
  ///
  /// In en, this message translates to:
  /// **'Budget name'**
  String get budgetName;

  /// No description provided for @spendingLimit.
  ///
  /// In en, this message translates to:
  /// **'Spending Limit'**
  String get spendingLimit;

  /// No description provided for @budgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Budget Limit'**
  String get budgetLimit;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @dailyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Daily Breakdown'**
  String get dailyBreakdown;

  /// No description provided for @dailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit'**
  String get dailyLimit;

  /// No description provided for @yourAverage.
  ///
  /// In en, this message translates to:
  /// **'Your average'**
  String get yourAverage;

  /// No description provided for @newBudget.
  ///
  /// In en, this message translates to:
  /// **'New Budget'**
  String get newBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @createFirstBudget.
  ///
  /// In en, this message translates to:
  /// **'Create First Budget'**
  String get createFirstBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @takeControlOfSpending.
  ///
  /// In en, this message translates to:
  /// **'Take control of your spending'**
  String get takeControlOfSpending;

  /// No description provided for @budgetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Budget not found'**
  String get budgetNotFound;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @projectedOverspend.
  ///
  /// In en, this message translates to:
  /// **'Projected overspend'**
  String get projectedOverspend;

  /// No description provided for @pleaseEnterBudgetName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a budget name'**
  String get pleaseEnterBudgetName;

  /// No description provided for @pleaseEnterValidLimit.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid limit'**
  String get pleaseEnterValidLimit;

  /// No description provided for @periodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodMonthly;

  /// No description provided for @periodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get periodWeekly;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get periodCustom;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get defaultCurrency;

  /// No description provided for @launchPage.
  ///
  /// In en, this message translates to:
  /// **'Launch Page'**
  String get launchPage;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @welcomeToWiseBudget.
  ///
  /// In en, this message translates to:
  /// **'Welcome to WiseBudget'**
  String get welcomeToWiseBudget;

  /// No description provided for @trackEveryTransaction.
  ///
  /// In en, this message translates to:
  /// **'Track Every Transaction'**
  String get trackEveryTransaction;

  /// No description provided for @gainFinancialInsights.
  ///
  /// In en, this message translates to:
  /// **'Gain Financial Insights'**
  String get gainFinancialInsights;

  /// No description provided for @pleaseEnterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Please enter account name'**
  String get pleaseEnterAccountName;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @failedToCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to create account'**
  String get failedToCreateAccount;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @mayShort.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get mayShort;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @adjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get adjustment;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @doneCount.
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String doneCount(int count);

  /// No description provided for @nAccountsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} accounts'**
  String nAccountsSelected(int count);

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select destination'**
  String get selectDestination;

  /// No description provided for @selectDestinationAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Destination Account'**
  String get selectDestinationAccount;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get noCategory;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @areYouSureDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get areYouSureDeleteTransaction;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @areYouSureDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get areYouSureDeleteCategory;

  /// No description provided for @areYouSureDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account?'**
  String get areYouSureDeleteAccount;

  /// No description provided for @areYouSureDeleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget?'**
  String get areYouSureDeleteBudget;

  /// No description provided for @areYouSureDeleteNamed.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String areYouSureDeleteNamed(String name);

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @newAccount.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get newAccount;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @noAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No Accounts Yet'**
  String get noAccountsYet;

  /// No description provided for @addFirstAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first account to start tracking your finances'**
  String get addFirstAccountDescription;

  /// No description provided for @searchAccounts.
  ///
  /// In en, this message translates to:
  /// **'Search accounts'**
  String get searchAccounts;

  /// No description provided for @failedToLoadAccounts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load accounts'**
  String get failedToLoadAccounts;

  /// No description provided for @failedToLoadBudgets.
  ///
  /// In en, this message translates to:
  /// **'Failed to load budgets'**
  String get failedToLoadBudgets;

  /// No description provided for @noBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsYet;

  /// No description provided for @setBudgetToTrack.
  ///
  /// In en, this message translates to:
  /// **'Set a budget to track your spending'**
  String get setBudgetToTrack;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @moreColors.
  ///
  /// In en, this message translates to:
  /// **'More colors'**
  String get moreColors;

  /// No description provided for @moreIcons.
  ///
  /// In en, this message translates to:
  /// **'More icons'**
  String get moreIcons;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select account'**
  String get selectAccount;

  /// No description provided for @resetsEveryMonday.
  ///
  /// In en, this message translates to:
  /// **'Resets every Monday'**
  String get resetsEveryMonday;

  /// No description provided for @resetsEveryMonth.
  ///
  /// In en, this message translates to:
  /// **'Resets on the 1st of each month'**
  String get resetsEveryMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get customRange;

  /// No description provided for @pickStartAndEndDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a start and end date'**
  String get pickStartAndEndDate;

  /// No description provided for @noCategoriesOfType.
  ///
  /// In en, this message translates to:
  /// **'No {type} categories'**
  String noCategoriesOfType(String type);

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearAllDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all accounts, transactions, budgets, and categories. This action cannot be undone.'**
  String get clearAllDataConfirmation;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @choosePeriod.
  ///
  /// In en, this message translates to:
  /// **'Choose period'**
  String get choosePeriod;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @spentAmount.
  ///
  /// In en, this message translates to:
  /// **'Spent {amount}'**
  String spentAmount(String amount);

  /// No description provided for @overByAmount.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String overByAmount(String amount);

  /// No description provided for @amountLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String amountLeft(String amount);

  /// No description provided for @amountRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String amountRemaining(String amount);

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'Transactions ({count})'**
  String transactionsCount(int count);

  /// No description provided for @daysLeftInPeriod.
  ///
  /// In en, this message translates to:
  /// **'{days} days left in {period}'**
  String daysLeftInPeriod(int days, String period);

  /// No description provided for @spendingAbovePace.
  ///
  /// In en, this message translates to:
  /// **'Spending {percent}% above daily pace'**
  String spendingAbovePace(String percent);

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountNameLabel;

  /// No description provided for @setUpAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Set up an account to start tracking your finances'**
  String get setUpAccountDescription;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance (optional)'**
  String get initialBalance;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name is too long (max 50 chars)'**
  String get nameTooLong;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Take control of your finances with simple, intuitive tracking'**
  String get onboardingDescription1;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Record income, expenses, and transfers across multiple accounts'**
  String get onboardingDescription2;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Understand your spending habits and make smarter decisions'**
  String get onboardingDescription3;

  /// No description provided for @cashSavingsExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Cash, Savings, Credit Card'**
  String get cashSavingsExample;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
