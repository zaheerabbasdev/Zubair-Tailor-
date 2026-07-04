import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Language ─────────────────────────────────────
          _buildSectionHeader(context, l10n.language, Icons.language),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'en',
                  groupValue: localeProvider.locale.languageCode,
                  title: const Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Switch to English'),
                  secondary: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                  onChanged: (v) => localeProvider.setLocale(Locale(v!)),
                  activeColor: AppColors.primary,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                RadioListTile<String>(
                  value: 'ur',
                  groupValue: localeProvider.locale.languageCode,
                  title: const Text('اردو', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('اردو زبان میں تبدیل کریں'),
                  secondary: const Text('🇵🇰', style: TextStyle(fontSize: 22)),
                  onChanged: (v) => localeProvider.setLocale(Locale(v!)),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            )),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}
