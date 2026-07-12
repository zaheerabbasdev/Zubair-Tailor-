import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ur'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Zubair Tailors'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @totalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalCustomers;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @pendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get pendingOrders;

  /// No description provided for @readyOrders.
  ///
  /// In en, this message translates to:
  /// **'Ready Orders'**
  String get readyOrders;

  /// No description provided for @deliveredOrders.
  ///
  /// In en, this message translates to:
  /// **'Delivered Orders'**
  String get deliveredOrders;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @customerNumber.
  ///
  /// In en, this message translates to:
  /// **'Customer Number'**
  String get customerNumber;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurement;

  /// No description provided for @measurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// No description provided for @waist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist;

  /// No description provided for @shoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get shoulder;

  /// No description provided for @sleeve.
  ///
  /// In en, this message translates to:
  /// **'Sleeve'**
  String get sleeve;

  /// No description provided for @shirtLength.
  ///
  /// In en, this message translates to:
  /// **'Shirt Length'**
  String get shirtLength;

  /// No description provided for @shirtWidth.
  ///
  /// In en, this message translates to:
  /// **'Shirt Width'**
  String get shirtWidth;

  /// No description provided for @ghera.
  ///
  /// In en, this message translates to:
  /// **'Ghera'**
  String get ghera;

  /// No description provided for @pancha.
  ///
  /// In en, this message translates to:
  /// **'Pancha'**
  String get pancha;

  /// No description provided for @shalwarLength.
  ///
  /// In en, this message translates to:
  /// **'Shalwar Length'**
  String get shalwarLength;

  /// No description provided for @collar.
  ///
  /// In en, this message translates to:
  /// **'Collar'**
  String get collar;

  /// No description provided for @banType.
  ///
  /// In en, this message translates to:
  /// **'Ban Type'**
  String get banType;

  /// No description provided for @damanType.
  ///
  /// In en, this message translates to:
  /// **'Daman Type'**
  String get damanType;

  /// No description provided for @frontPocket.
  ///
  /// In en, this message translates to:
  /// **'Front Pocket'**
  String get frontPocket;

  /// No description provided for @sidePocket.
  ///
  /// In en, this message translates to:
  /// **'Side Pocket'**
  String get sidePocket;

  /// No description provided for @sleeveType.
  ///
  /// In en, this message translates to:
  /// **'Sleeve Type'**
  String get sleeveType;

  /// No description provided for @cuff.
  ///
  /// In en, this message translates to:
  /// **'Cuff'**
  String get cuff;

  /// No description provided for @shalwarPocket.
  ///
  /// In en, this message translates to:
  /// **'Shalwar Pocket'**
  String get shalwarPocket;

  /// No description provided for @ringButton.
  ///
  /// In en, this message translates to:
  /// **'Ring Button'**
  String get ringButton;

  /// No description provided for @doubleSilai.
  ///
  /// In en, this message translates to:
  /// **'Double Stitch'**
  String get doubleSilai;

  /// No description provided for @chamakTar.
  ///
  /// In en, this message translates to:
  /// **'Shiny Thread'**
  String get chamakTar;

  /// No description provided for @sadaPatti.
  ///
  /// In en, this message translates to:
  /// **'Simple Placket'**
  String get sadaPatti;

  /// No description provided for @designButton.
  ///
  /// In en, this message translates to:
  /// **'Design Button'**
  String get designButton;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @clothingType.
  ///
  /// In en, this message translates to:
  /// **'Clothing Type'**
  String get clothingType;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get deliveryDate;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this customer?'**
  String get deleteConfirm;

  /// No description provided for @deleteErrorOrders.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete customer with active orders'**
  String get deleteErrorOrders;

  /// No description provided for @ban.
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get ban;

  /// No description provided for @golBan.
  ///
  /// In en, this message translates to:
  /// **'Gol Ban'**
  String get golBan;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get square;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// No description provided for @gol.
  ///
  /// In en, this message translates to:
  /// **'Gol'**
  String get gol;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @double.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get double;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @stitchingDetails.
  ///
  /// In en, this message translates to:
  /// **'Stitching & Details'**
  String get stitchingDetails;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @customersLabel.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersLabel;

  /// No description provided for @ordersLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersLabel;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @upcomingDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Deliveries'**
  String get upcomingDeliveries;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @tapToAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add a new customer'**
  String get tapToAddCustomer;

  /// No description provided for @noMeasurementsFound.
  ///
  /// In en, this message translates to:
  /// **'No measurements found'**
  String get noMeasurementsFound;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @editMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Edit Measurement'**
  String get editMeasurement;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdOn(String date);

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @dueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueLabel;

  /// No description provided for @noOrdersFoundFilter.
  ///
  /// In en, this message translates to:
  /// **'No {filter} orders found'**
  String noOrdersFoundFilter(String filter);

  /// No description provided for @tapToCreateOrder.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to create a new order'**
  String get tapToCreateOrder;

  /// No description provided for @editOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit Order'**
  String get editOrder;

  /// No description provided for @detailsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsSectionTitle;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @pleaseSelectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer'**
  String get pleaseSelectCustomer;

  /// No description provided for @pleaseSelectMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Please select a measurement'**
  String get pleaseSelectMeasurement;

  /// No description provided for @pleaseEnterClothingType.
  ///
  /// In en, this message translates to:
  /// **'Please enter clothing type'**
  String get pleaseEnterClothingType;

  /// No description provided for @pleaseEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter price'**
  String get pleaseEnterPrice;

  /// No description provided for @overpaidWarning.
  ///
  /// In en, this message translates to:
  /// **'Amount paid is more than the price — please double-check.'**
  String get overpaidWarning;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @addReferencePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Reference Photo'**
  String get addReferencePhoto;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @failedToSaveOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to save order'**
  String get failedToSaveOrder;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @customerUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Customer updated successfully!'**
  String get customerUpdatedSuccess;

  /// No description provided for @customerAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Customer added successfully!'**
  String get customerAddedSuccess;

  /// No description provided for @failedToSaveCustomer.
  ///
  /// In en, this message translates to:
  /// **'Failed to save customer'**
  String get failedToSaveCustomer;

  /// No description provided for @addFraction.
  ///
  /// In en, this message translates to:
  /// **'Add Fraction'**
  String get addFraction;

  /// No description provided for @errorSavingMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Error saving measurements'**
  String get errorSavingMeasurement;

  /// No description provided for @noUpcomingDeliveries.
  ///
  /// In en, this message translates to:
  /// **'No upcoming deliveries'**
  String get noUpcomingDeliveries;

  /// No description provided for @deliveryDateWillShow.
  ///
  /// In en, this message translates to:
  /// **'Orders with a delivery date will show up here'**
  String get deliveryDateWillShow;

  /// No description provided for @overdueSince.
  ///
  /// In en, this message translates to:
  /// **'Overdue — was due {date}'**
  String overdueSince(String date);

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @revenueCollected.
  ///
  /// In en, this message translates to:
  /// **'Revenue Collected'**
  String get revenueCollected;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @totalCustomersAllTime.
  ///
  /// In en, this message translates to:
  /// **'Total Customers (All Time)'**
  String get totalCustomersAllTime;

  /// No description provided for @ordersByStatus.
  ///
  /// In en, this message translates to:
  /// **'Orders by Status'**
  String get ordersByStatus;

  /// No description provided for @ordersByClothingType.
  ///
  /// In en, this message translates to:
  /// **'Orders by Clothing Type'**
  String get ordersByClothingType;

  /// No description provided for @noOrdersInRange.
  ///
  /// In en, this message translates to:
  /// **'No orders in this range'**
  String get noOrdersInRange;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @noExpensesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded yet'**
  String get noExpensesRecorded;

  /// No description provided for @tapToAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Expense\" to record your first one'**
  String get tapToAddExpense;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get deleteExpenseConfirm;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @failedToSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to save expense'**
  String get failedToSaveExpense;

  /// No description provided for @expenseCategoryFabric.
  ///
  /// In en, this message translates to:
  /// **'Fabric / Material'**
  String get expenseCategoryFabric;

  /// No description provided for @expenseCategoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get expenseCategoryRent;

  /// No description provided for @expenseCategoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get expenseCategoryUtilities;

  /// No description provided for @expenseCategorySalaries.
  ///
  /// In en, this message translates to:
  /// **'Salaries'**
  String get expenseCategorySalaries;

  /// No description provided for @expenseCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseCategoryOther;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch the app to a dark color scheme'**
  String get darkModeSubtitle;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @pinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN Lock'**
  String get pinLock;

  /// No description provided for @pinLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require a 4-digit PIN to open the app'**
  String get pinLockSubtitle;

  /// No description provided for @enterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPin;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @systemInfo.
  ///
  /// In en, this message translates to:
  /// **'System Info'**
  String get systemInfo;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// No description provided for @databaseStatus.
  ///
  /// In en, this message translates to:
  /// **'Database Status'**
  String get databaseStatus;

  /// No description provided for @localSyncOnline.
  ///
  /// In en, this message translates to:
  /// **'Local Sync Online'**
  String get localSyncOnline;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your customers and orders as CSV files you can open in Excel or share elsewhere.'**
  String get exportDescription;

  /// No description provided for @exportOrdersCsv.
  ///
  /// In en, this message translates to:
  /// **'Export Orders (CSV)'**
  String get exportOrdersCsv;

  /// No description provided for @exportCustomersCsv.
  ///
  /// In en, this message translates to:
  /// **'Export Customers (CSV)'**
  String get exportCustomersCsv;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @connectGoogleDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect your Google account to automatically back up your customers, measurements, and orders to Google Drive.'**
  String get connectGoogleDescription;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @connectGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Account'**
  String get connectGoogleAccount;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last Backup'**
  String get lastBackup;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working...'**
  String get working;

  /// No description provided for @backUpNow.
  ///
  /// In en, this message translates to:
  /// **'Back Up Now'**
  String get backUpNow;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackup;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @backupCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup completed successfully'**
  String get backupCompletedSuccess;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailed;

  /// No description provided for @failedToLoadBackups.
  ///
  /// In en, this message translates to:
  /// **'Failed to load backups'**
  String get failedToLoadBackups;

  /// No description provided for @noBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'No backups found yet'**
  String get noBackupsFound;

  /// No description provided for @restoreBackupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get restoreBackupQuestion;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite all local data with the backup from {date}. This cannot be undone.'**
  String restoreWarning(String date);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailed;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @moreApps.
  ///
  /// In en, this message translates to:
  /// **'More Apps'**
  String get moreApps;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit?'**
  String get exitConfirm;

  /// No description provided for @couldntOpenPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the Play Store'**
  String get couldntOpenPlayStore;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by Zaheer Tech'**
  String get developedBy;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 (Premium)'**
  String get versionLabel;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get setPin;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs didn\'t match — try again'**
  String get pinMismatch;

  /// No description provided for @shopProfile.
  ///
  /// In en, this message translates to:
  /// **'Shop Profile'**
  String get shopProfile;

  /// No description provided for @shopProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Your shop\'s name, phone, and address appear on invoices and customer WhatsApp messages.'**
  String get shopProfileDescription;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopName;

  /// No description provided for @pleaseEnterShopName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a shop name'**
  String get pleaseEnterShopName;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Shop profile saved'**
  String get profileSaved;
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
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
