import '../l10n/app_localizations.dart';

String localizedStatus(AppLocalizations l10n, String status) {
  switch (status) {
    case 'All':
      return l10n.all;
    case 'Pending':
      return l10n.pending;
    case 'In Progress':
      return l10n.inProgress;
    case 'Ready':
      return l10n.ready;
    case 'Delivered':
      return l10n.delivered;
    default:
      return status;
  }
}

String localizedRange(AppLocalizations l10n, String range) {
  switch (range) {
    case 'This Month':
      return l10n.thisMonth;
    case 'Last 30 Days':
      return l10n.last30Days;
    case 'All Time':
      return l10n.allTime;
    default:
      return range;
  }
}

String localizedExpenseCategory(AppLocalizations l10n, String category) {
  switch (category) {
    case 'Fabric / Material':
      return l10n.expenseCategoryFabric;
    case 'Rent':
      return l10n.expenseCategoryRent;
    case 'Utilities':
      return l10n.expenseCategoryUtilities;
    case 'Salaries':
      return l10n.expenseCategorySalaries;
    case 'Other':
      return l10n.expenseCategoryOther;
    default:
      return category;
  }
}
