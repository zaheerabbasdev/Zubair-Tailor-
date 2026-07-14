import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../providers/shop_profile_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../screens/customer_list_screen.dart';
import '../screens/expense_list_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/order_list_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/upcoming_deliveries_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    AppColors.dark = context.watch<ThemeProvider>().isDark;
    final l10n = AppLocalizations.of(context)!;
    final shopName = context.watch<ShopProfileProvider>().shopName;

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            accountName: Text(
              shopName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1, color: Colors.white),
            ),
            accountEmail: Text(
              l10n.developedBy,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Image(
                    image: AssetImage('assets/images/icon.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
          _buildDrawerItem(
            icon: Icons.dashboard_rounded,
            title: l10n.dashboard,
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.people_alt_rounded,
            title: l10n.customersLabel,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long_rounded,
            title: l10n.ordersLabel,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.local_shipping_outlined,
            title: l10n.upcomingDeliveries,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UpcomingDeliveriesScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart_rounded,
            title: l10n.reports,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.expenses,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen()));
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Color(0xFFE5D5C5), height: 1),
          ),
          _buildDrawerItem(
            icon: Icons.settings_rounded,
            title: l10n.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Color(0xFFE5D5C5), height: 1),
          ),
          _buildDrawerItem(
            icon: Icons.share_rounded,
            title: l10n.shareApp,
            onTap: () {
              Navigator.pop(context);
              _shareApp();
            },
          ),
          _buildDrawerItem(
            icon: Icons.apps_rounded,
            title: l10n.moreApps,
            onTap: () {
              Navigator.pop(context);
              _openMoreApps(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.exit_to_app_rounded,
            title: l10n.exit,
            onTap: () => _confirmExit(context, l10n),
          ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              l10n.versionLabel,
              style: TextStyle(color: AppColors.textMedium, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    Share.share(
      "Check out Zubair Tailors — manage your tailoring shop's customers, "
      "measurements, and orders. https://play.google.com/store/apps/details?id=com.zubair.tailors",
    );
  }

  Future<void> _openMoreApps(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse('https://play.google.com/store/apps/dev?id=Zaheer+Tech');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldntOpenPlayStore)),
      );
    }
  }

  void _confirmExit(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exitApp, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(l10n.exitConfirm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () => SystemNavigator.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.exit),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
      ),
      onTap: onTap,
    );
  }
}
