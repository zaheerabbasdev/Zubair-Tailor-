import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../l10n/app_localizations.dart';
import '../providers/app_lock_provider.dart';
import '../providers/backup_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/export_service.dart';
import '../utils/app_colors.dart';
import 'app_lock_screen.dart';
import 'dashboard_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppColors.dark = context.watch<ThemeProvider>().isDark;
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(context, l10n.language, Icons.language_rounded),
          const SizedBox(height: 12),

          // Custom visual Language cards
          Row(
            children: [
              Expanded(
                child: _buildLanguageCard(
                  title: 'English',
                  subtitle: 'English System',
                  flag: '🇬🇧',
                  isSelected: currentLocale == 'en',
                  onTap: () => localeProvider.setLocale(const Locale('en')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLanguageCard(
                  title: 'اردو',
                  subtitle: 'اردو سسٹم',
                  flag: '🇵🇰',
                  isSelected: currentLocale == 'ur',
                  onTap: () => localeProvider.setLocale(const Locale('ur')),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(context, l10n.appearance, Icons.dark_mode_outlined),
          const SizedBox(height: 12),
          Consumer<ThemeProvider>(
            builder: (context, theme, _) => _buildAppearanceCard(context, theme, l10n),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(context, l10n.appLock, Icons.lock_outline_rounded),
          const SizedBox(height: 12),
          Consumer<AppLockProvider>(
            builder: (context, lock, _) => _buildAppLockCard(context, lock, l10n),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(context, l10n.backupRestore, Icons.cloud_outlined),
          const SizedBox(height: 12),
          Consumer<BackupProvider>(
            builder: (context, backup, _) => _buildBackupCard(context, backup, l10n),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(context, l10n.exportData, Icons.file_download_outlined),
          const SizedBox(height: 12),
          _buildExportCard(context, l10n),

          const SizedBox(height: 32),
          _buildSectionHeader(context, l10n.systemInfo, Icons.info_outline_rounded),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.cardShadow,
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Column(
              children: [
                _buildInfoRow(l10n.appVersion, "1.0.0 (Premium)"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                _buildInfoRow(l10n.publisher, "Zubair Tech"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                _buildInfoRow(l10n.databaseStatus, l10n.localSyncOnline),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(BuildContext context, ThemeProvider theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          l10n.darkMode,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15),
        ),
        subtitle: Text(
          l10n.darkModeSubtitle,
          style: TextStyle(color: AppColors.textMedium, fontSize: 12),
        ),
        value: theme.isDark,
        activeThumbColor: AppColors.primary,
        onChanged: (value) => theme.setDark(value),
      ),
    );
  }

  Widget _buildExportCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.exportDescription,
            style: TextStyle(color: AppColors.textMedium, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _exportOrders(context),
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: Text(l10n.exportOrdersCsv),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _exportCustomers(context),
            icon: const Icon(Icons.people_outline_rounded, size: 18),
            label: Text(l10n.exportCustomersCsv),
          ),
        ],
      ),
    );
  }

  Future<void> _exportOrders(BuildContext context) async {
    try {
      await ExportService.exportOrdersCsv();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.exportFailed}: $e")),
        );
      }
    }
  }

  Widget _buildAppLockCard(BuildContext context, AppLockProvider lock, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          l10n.pinLock,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15),
        ),
        subtitle: Text(
          l10n.pinLockSubtitle,
          style: TextStyle(color: AppColors.textMedium, fontSize: 12),
        ),
        value: lock.isEnabled,
        activeThumbColor: AppColors.primary,
        onChanged: (value) => value ? _enableLock(context) : _disableLock(context, lock),
      ),
    );
  }

  Future<void> _enableLock(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppLockScreen(isSetup: true), fullscreenDialog: true),
    );
  }

  Future<void> _disableLock(BuildContext context, AppLockProvider lock) async {
    final l10n = AppLocalizations.of(context)!;
    final pinController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.enterCurrentPin, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(counterText: ''),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () async {
              final correct = await lock.verifyPin(pinController.text);
              if (dialogContext.mounted) Navigator.pop(dialogContext, correct);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await lock.disable();
    } else if (confirmed == false && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.incorrectPin)),
      );
    }
  }

  Future<void> _exportCustomers(BuildContext context) async {
    try {
      await ExportService.exportCustomersCsv();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.exportFailed}: $e")),
        );
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceCard : AppColors.surfaceCard.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppColors.cardShadow : [],
        ),
        child: Column(
          children: [
            Text(flag, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary.withOpacity(0.7) : AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMedium, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBackupCard(BuildContext context, BackupProvider backup, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!backup.isSignedIn) ...[
            Text(
              l10n.connectGoogleDescription,
              style: TextStyle(color: AppColors.textMedium, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: backup.isBusy ? null : () => backup.signIn(),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: Text(backup.isBusy ? l10n.connecting : l10n.connectGoogleAccount),
            ),
          ] else ...[
            _buildInfoRow(l10n.account, backup.accountEmail ?? "-"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: AppColors.divider, height: 1),
            ),
            _buildInfoRow(l10n.lastBackup, _formatLastBackup(backup.lastBackupAt, l10n)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: backup.isBusy ? null : () => _backupNow(context, backup),
              icon: backup.isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.backup_rounded, size: 18),
              label: Text(backup.isBusy ? l10n.working : l10n.backUpNow),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: backup.isBusy ? null : () => _showRestoreSheet(context, backup),
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: Text(l10n.restoreBackup),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: backup.isBusy ? null : () => backup.signOut(),
                  child: Text(l10n.disconnect),
                ),
              ],
            ),
          ],
          if (backup.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              backup.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  String _formatLastBackup(DateTime? time, AppLocalizations l10n) {
    if (time == null) return l10n.never;
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  String _formatFullDate(DateTime dt) {
    final local = dt.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${pad(local.month)}-${pad(local.day)} ${pad(local.hour)}:${pad(local.minute)}';
  }

  Future<void> _backupNow(BuildContext context, BackupProvider backup) async {
    final l10n = AppLocalizations.of(context)!;
    await backup.backupNow();
    if (!context.mounted) return;
    if (backup.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupCompletedSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.backupFailed}: ${backup.errorMessage}")),
      );
    }
  }

  Future<void> _showRestoreSheet(BuildContext context, BackupProvider backup) async {
    final l10n = AppLocalizations.of(context)!;
    List<drive.File> backups;
    try {
      backups = await backup.listBackups();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${l10n.failedToLoadBackups}: $e")),
        );
      }
      return;
    }

    if (!context.mounted) return;

    if (backups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noBackupsFound)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.restoreBackup,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: backups.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (itemContext, index) {
                    final file = backups[index];
                    final created = file.createdTime;
                    return ListTile(
                      leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                      title: Text(created != null ? _formatFullDate(created) : (file.name ?? 'Backup')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _confirmRestore(context, backup, file);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRestore(BuildContext context, BackupProvider backup, drive.File file) async {
    final l10n = AppLocalizations.of(context)!;
    final created = file.createdTime;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.restoreBackupQuestion),
        content: Text(
          l10n.restoreWarning(created != null ? _formatFullDate(created) : 'this backup'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    if (file.id == null) return;

    await backup.restoreFrom(file.id!);
    if (!context.mounted) return;

    if (backup.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.restoreFailed}: ${backup.errorMessage}")),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }
}
