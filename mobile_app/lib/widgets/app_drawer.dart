import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../screens/customer_list_screen.dart';
import '../screens/order_list_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            accountName: Text(
              l10n.appName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1, color: Colors.white),
            ),
            accountEmail: const Text(
              "Developed by Zubair Tech",
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
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
          _buildDrawerItem(
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.people_alt_rounded,
            title: l10n.totalCustomers,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long_rounded,
            title: l10n.totalOrders,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()));
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
            title: "Share App",
            onTap: () {
              Navigator.pop(context);
              _shareApp();
            },
          ),
          _buildDrawerItem(
            icon: Icons.apps_rounded,
            title: "More Apps",
            onTap: () {
              Navigator.pop(context);
              _openMoreApps(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.exit_to_app_rounded,
            title: "Exit",
            onTap: () => _confirmExit(context),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              "Version 1.0.0 (Premium)",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
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
    final uri = Uri.parse('https://play.google.com/store/apps/dev?id=Zubair+Tech');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the Play Store")),
      );
    }
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Exit App", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to exit?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => SystemNavigator.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Exit"),
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
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
      ),
      onTap: onTap,
    );
  }
}
