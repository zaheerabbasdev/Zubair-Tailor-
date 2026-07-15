import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../providers/backup_provider.dart';
import '../providers/theme_provider.dart';
import '../repositories/customer_repository.dart';
import '../repositories/order_repository.dart';
import '../services/notification_service.dart';
import '../widgets/app_drawer.dart';
import 'customer_list_screen.dart';
import 'order_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final OrderRepository _orderRepository = OrderRepository();


  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
    context.read<BackupProvider>().autoBackupOnOpen();
    NotificationService.instance.rescheduleAll().catchError((_) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchSummary() async {
    try {
      final customers = await _customerRepository.getAll();
      final orders = await _orderRepository.getAll();
      if (mounted) {
        setState(() {


          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
          final monthStart = DateTime(now.year, now.month, 1);
          double todayRevenue = 0, weekRevenue = 0, monthRevenue = 0, outstanding = 0;
          for (final o in orders) {
            final due = o.price - o.amountPaid;
            if (due > 0) outstanding += due;
            if (o.createdAt != null) {
              if (!o.createdAt!.isBefore(todayStart)) todayRevenue += o.amountPaid;
              if (!o.createdAt!.isBefore(weekStart)) weekRevenue += o.amountPaid;
              if (!o.createdAt!.isBefore(monthStart)) monthRevenue += o.amountPaid;
            }
          }
          _summary = {
            'total_customers': customers.length,
            'total_orders': orders.length,
            'pending_orders': orders.where((o) => o.status == 'Pending').length,
            'ready_orders': orders.where((o) => o.status == 'Ready').length,
            'today_revenue': todayRevenue.toInt(),
            'week_revenue': weekRevenue.toInt(),
            'month_revenue': monthRevenue.toInt(),
            'outstanding': outstanding.toInt(),
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    AppColors.dark = context.watch<ThemeProvider>().isDark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSummary,
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                children: [
                  ..._buildDashboardContent(l10n),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildDashboardContent(AppLocalizations l10n) {
    return [
      // Summary Cards Row 1
      Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: l10n.today,
              value: 'Rs. ${_summary?['today_revenue'] ?? 0}',
              icon: Icons.today_rounded,
              accentColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: l10n.thisWeek,
              value: 'Rs. ${_summary?['week_revenue'] ?? 0}',
              icon: Icons.date_range_rounded,
              accentColor: Colors.indigo,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: l10n.thisMonth,
              value: 'Rs. ${_summary?['month_revenue'] ?? 0}',
              icon: Icons.calendar_month_rounded,
              accentColor: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: l10n.outstanding,
              value: 'Rs. ${_summary?['outstanding'] ?? 0}',
              icon: Icons.account_balance_wallet_outlined,
              accentColor: AppColors.statusPending,
            ),
          ),
        ],
      ),

      const SizedBox(height: 28),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.status,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          Icon(Icons.analytics_outlined, color: AppColors.iconMuted, size: 20),
        ],
      ),
      const SizedBox(height: 16),

      // Status Stats Grid
      _buildStatsGrid(),
      const SizedBox(height: 28),

      // Quick Action Buttons (moved below status cards)
      Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              l10n.addCustomer,
              Icons.person_add_rounded,
              AppColors.primary,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())).then((_) => _fetchSummary()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              context,
              l10n.newOrder,
              Icons.add_task_rounded,
              AppColors.secondary,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen())).then((_) => _fetchSummary()),
            ),
          ),
        ],
      ),
      const SizedBox(height: 32),
    ];
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: AppLocalizations.of(context)!.totalCustomers,
                value: _summary?['total_customers']?.toString() ?? '0',
                icon: Icons.people_outline_rounded,
                accentColor: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: AppLocalizations.of(context)!.totalOrders,
                value: _summary?['total_orders']?.toString() ?? '0',
                icon: Icons.assignment_outlined,
                accentColor: const Color(0xFF5D4037),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: AppLocalizations.of(context)!.pendingOrders,
                value: _summary?['pending_orders']?.toString() ?? '0',
                icon: Icons.history_toggle_off_rounded,
                accentColor: AppColors.statusPending,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: AppLocalizations.of(context)!.readyOrders,
                value: _summary?['ready_orders']?.toString() ?? '0',
                icon: Icons.check_circle_outline_rounded,
                accentColor: AppColors.statusReady,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accentColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }


}
