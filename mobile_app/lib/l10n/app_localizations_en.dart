// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Zubair Tailors';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get totalCustomers => 'Total Customers';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get pendingOrders => 'Pending Orders';

  @override
  String get readyOrders => 'Ready Orders';

  @override
  String get deliveredOrders => 'Delivered Orders';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get customerNumber => 'Customer Number';

  @override
  String get customerName => 'Customer Name';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get save => 'Save';

  @override
  String get addMeasurement => 'Add Measurement';

  @override
  String get measurements => 'Measurements';

  @override
  String get chest => 'Chest';

  @override
  String get waist => 'Waist';

  @override
  String get shoulder => 'Shoulder';

  @override
  String get sleeve => 'Sleeve';

  @override
  String get shirtLength => 'Shirt Length';

  @override
  String get shirtWidth => 'Shirt Width';

  @override
  String get ghera => 'Ghera';

  @override
  String get pancha => 'Pancha';

  @override
  String get shalwarLength => 'Shalwar Length';

  @override
  String get collar => 'Collar';

  @override
  String get banType => 'Ban Type';

  @override
  String get damanType => 'Daman Type';

  @override
  String get frontPocket => 'Front Pocket';

  @override
  String get sidePocket => 'Side Pocket';

  @override
  String get sleeveType => 'Sleeve Type';

  @override
  String get cuff => 'Cuff';

  @override
  String get shalwarPocket => 'Shalwar Pocket';

  @override
  String get ringButton => 'Ring Button';

  @override
  String get doubleSilai => 'Double Stitch';

  @override
  String get chamakTar => 'Shiny Thread';

  @override
  String get sadaPatti => 'Simple Placket';

  @override
  String get designButton => 'Design Button';

  @override
  String get notes => 'Notes';

  @override
  String get newOrder => 'New Order';

  @override
  String get clothingType => 'Clothing Type';

  @override
  String get price => 'Price';

  @override
  String get deliveryDate => 'Delivery Date';

  @override
  String get status => 'Status';

  @override
  String get pending => 'Pending';

  @override
  String get inProgress => 'In Progress';

  @override
  String get ready => 'Ready';

  @override
  String get delivered => 'Delivered';

  @override
  String get signOut => 'Sign Out';

  @override
  String get search => 'Search';

  @override
  String get history => 'History';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this customer?';

  @override
  String get deleteErrorOrders => 'Cannot delete customer with active orders';

  @override
  String get ban => 'Ban';

  @override
  String get golBan => 'Gol Ban';

  @override
  String get none => 'None';

  @override
  String get square => 'Square';

  @override
  String get round => 'Round';

  @override
  String get gol => 'Gol';

  @override
  String get single => 'Single';

  @override
  String get double => 'Double';

  @override
  String get style => 'Style';

  @override
  String get stitchingDetails => 'Stitching & Details';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get edit => 'Edit';

  @override
  String get unknown => 'Unknown';

  @override
  String get all => 'All';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get customersLabel => 'Customers';

  @override
  String get ordersLabel => 'Orders';

  @override
  String get navigation => 'Navigation';

  @override
  String get upcomingDeliveries => 'Upcoming Deliveries';

  @override
  String get reports => 'Reports';

  @override
  String get expenses => 'Expenses';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get na => 'N/A';

  @override
  String get noCustomersFound => 'No customers found';

  @override
  String get tapToAddCustomer => 'Tap the + button to add a new customer';

  @override
  String get noMeasurementsFound => 'No measurements found';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get editMeasurement => 'Edit Measurement';

  @override
  String createdOn(String date) {
    return 'Created: $date';
  }

  @override
  String get dimensions => 'Dimensions';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get invoice => 'Invoice';

  @override
  String get dueLabel => 'Due';

  @override
  String noOrdersFoundFilter(String filter) {
    return 'No $filter orders found';
  }

  @override
  String get tapToCreateOrder => 'Tap the + button to create a new order';

  @override
  String get editOrder => 'Edit Order';

  @override
  String get detailsSectionTitle => 'Details';

  @override
  String get amountPaid => 'Amount Paid';

  @override
  String get pleaseSelectCustomer => 'Please select a customer';

  @override
  String get pleaseSelectMeasurement => 'Please select a measurement';

  @override
  String get pleaseEnterClothingType => 'Please enter clothing type';

  @override
  String get pleaseEnterPrice => 'Please enter price';

  @override
  String get overpaidWarning =>
      'Amount paid is more than the price — please double-check.';

  @override
  String get selectDate => 'Select Date';

  @override
  String get urgent => 'Urgent';

  @override
  String get addReferencePhoto => 'Add Reference Photo';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get failedToSaveOrder => 'Failed to save order';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get pleaseEnterPhone => 'Please enter a phone number';

  @override
  String get customerUpdatedSuccess => 'Customer updated successfully!';

  @override
  String get customerAddedSuccess => 'Customer added successfully!';

  @override
  String get failedToSaveCustomer => 'Failed to save customer';

  @override
  String get addFraction => 'Add Fraction';

  @override
  String get errorSavingMeasurement => 'Error saving measurements';

  @override
  String get noUpcomingDeliveries => 'No upcoming deliveries';

  @override
  String get deliveryDateWillShow =>
      'Orders with a delivery date will show up here';

  @override
  String overdueSince(String date) {
    return 'Overdue — was due $date';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get thisMonth => 'This Month';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get allTime => 'All Time';

  @override
  String get revenueCollected => 'Revenue Collected';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get totalCustomersAllTime => 'Total Customers (All Time)';

  @override
  String get ordersByStatus => 'Orders by Status';

  @override
  String get ordersByClothingType => 'Orders by Clothing Type';

  @override
  String get noOrdersInRange => 'No orders in this range';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get noExpensesRecorded => 'No expenses recorded yet';

  @override
  String get tapToAddExpense => 'Tap \"Add Expense\" to record your first one';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get deleteExpenseConfirm =>
      'Are you sure you want to delete this expense?';

  @override
  String get category => 'Category';

  @override
  String get amount => 'Amount';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get date => 'Date';

  @override
  String get failedToSaveExpense => 'Failed to save expense';

  @override
  String get expenseCategoryFabric => 'Fabric / Material';

  @override
  String get expenseCategoryRent => 'Rent';

  @override
  String get expenseCategoryUtilities => 'Utilities';

  @override
  String get expenseCategorySalaries => 'Salaries';

  @override
  String get expenseCategoryOther => 'Other';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Switch the app to a dark color scheme';

  @override
  String get appLock => 'App Lock';

  @override
  String get pinLock => 'PIN Lock';

  @override
  String get pinLockSubtitle => 'Require a 4-digit PIN to open the app';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get exportData => 'Export Data';

  @override
  String get systemInfo => 'System Info';

  @override
  String get appVersion => 'App Version';

  @override
  String get publisher => 'Publisher';

  @override
  String get databaseStatus => 'Database Status';

  @override
  String get localSyncOnline => 'Local Sync Online';

  @override
  String get exportDescription =>
      'Export your customers and orders as CSV files you can open in Excel or share elsewhere.';

  @override
  String get exportOrdersCsv => 'Export Orders (CSV)';

  @override
  String get exportCustomersCsv => 'Export Customers (CSV)';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get connectGoogleDescription =>
      'Connect your Google account to automatically back up your customers, measurements, and orders to Google Drive.';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connectGoogleAccount => 'Connect Google Account';

  @override
  String get account => 'Account';

  @override
  String get lastBackup => 'Last Backup';

  @override
  String get working => 'Working...';

  @override
  String get backUpNow => 'Back Up Now';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get never => 'Never';

  @override
  String get justNow => 'Just now';

  @override
  String get backupCompletedSuccess => 'Backup completed successfully';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get failedToLoadBackups => 'Failed to load backups';

  @override
  String get noBackupsFound => 'No backups found yet';

  @override
  String get restoreBackupQuestion => 'Restore this backup?';

  @override
  String restoreWarning(String date) {
    return 'This will overwrite all local data with the backup from $date. This cannot be undone.';
  }

  @override
  String get restore => 'Restore';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get shareApp => 'Share App';

  @override
  String get moreApps => 'More Apps';

  @override
  String get exit => 'Exit';

  @override
  String get exitApp => 'Exit App';

  @override
  String get exitConfirm => 'Are you sure you want to exit?';

  @override
  String get couldntOpenPlayStore => 'Couldn\'t open the Play Store';

  @override
  String get developedBy => 'Developed by Zaheer Tech';

  @override
  String get versionLabel => 'Version 1.0.0 (Premium)';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get setPin => 'Set a PIN';

  @override
  String get pinMismatch => 'PINs didn\'t match — try again';

  @override
  String get shopProfile => 'Shop Profile';

  @override
  String get shopProfileDescription =>
      'Your shop\'s name, phone, and address appear on invoices and customer WhatsApp messages.';

  @override
  String get shopName => 'Shop Name';

  @override
  String get pleaseEnterShopName => 'Please enter a shop name';

  @override
  String get profileSaved => 'Shop profile saved';
}
