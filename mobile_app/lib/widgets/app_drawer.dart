import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../providers/locale_provider.dart';
import '../screens/customer_list_screen.dart';
import '../screens/order_list_screen.dart';
import '../screens/splash_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(l10n.appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            accountEmail: const Text("Developed by Zubair Tech"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/icon.png'),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(l10n.totalCustomers), // Using l10n for "Customers" or similar if available
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: Text(l10n.totalOrders), // Using l10n for "Orders"
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()));
            },
          ),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            children: [
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: localeProvider.locale.languageCode,
                  onChanged: (value) => localeProvider.setLocale(Locale(value!)),
                ),
                onTap: () => localeProvider.setLocale(const Locale('en')),
              ),
              ListTile(
                title: const Text('اردو (Urdu)'),
                leading: Radio<String>(
                  value: 'ur',
                  groupValue: localeProvider.locale.languageCode,
                  onChanged: (value) => localeProvider.setLocale(Locale(value!)),
                ),
                onTap: () => localeProvider.setLocale(const Locale('ur')),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
