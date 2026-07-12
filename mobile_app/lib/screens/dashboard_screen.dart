import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../utils/app_colors.dart';
import '../providers/backup_provider.dart';
import '../providers/theme_provider.dart';
import '../repositories/customer_repository.dart';
import '../repositories/order_repository.dart';
import '../services/notification_service.dart';
import '../utils/status_helper.dart';
import '../widgets/app_drawer.dart';
import 'customer_detail_screen.dart';
import 'customer_list_screen.dart';
import 'order_list_screen.dart';
import 'upcoming_deliveries_screen.dart';
import 'reports_screen.dart';
import 'expense_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _searchController = TextEditingController();

  List<Customer> _customers = [];
  List<Order> _orders = [];
  Map<String, dynamic>? _summary;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSummary();
    context.read<BackupProvider>().autoBackupOnOpen();
    NotificationService.instance.rescheduleAll().catchError((_) {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSummary() async {
    try {
      final customers = await _customerRepository.getAll();
      final orders = await _orderRepository.getAll();
      if (mounted) {
        setState(() {
          _customers = customers;
          _orders = orders;
          _summary = {
            'total_customers': customers.length,
            'total_orders': orders.length,
            'pending_orders': orders.where((o) => o.status == 'Pending').length,
            'ready_orders': orders.where((o) => o.status == 'Ready').length,
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

  List<Customer> get _matchingCustomers {
    final q = _searchQuery.toLowerCase();
    return _customers
        .where((c) => c.name.toLowerCase().contains(q) || c.phone.contains(q) || (c.uniqueId != null && c.uniqueId!.contains(q)))
        .toList();
  }

  List<Order> get _matchingOrders {
    final q = _searchQuery.toLowerCase();
    return _orders
        .where((o) => (o.customerName ?? '').toLowerCase().contains(q) || o.clothingType.toLowerCase().contains(q))
        .toList();
  }

  Customer? _customerFor(Order o) {
    for (final c in _customers) {
      if (c.id == o.customerId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    AppColors.dark = context.watch<ThemeProvider>().isDark;
    final l10n = AppLocalizations.of(context)!;
    final isSearching = _searchQuery.isNotEmpty;

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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: l10n.search,
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      suffixIcon: isSearching
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: AppColors.textMedium),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      fillColor: AppColors.surfaceCard,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (isSearching)
                    ..._buildSearchResults()
                  else
                    ..._buildDashboardContent(l10n),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildSearchResults() {
    final l10n = AppLocalizations.of(context)!;
    final customers = _matchingCustomers;
    final orders = _matchingOrders;

    if (customers.isEmpty && orders.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              l10n.noResultsFound,
              style: TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ];
    }

    return [
      if (customers.isNotEmpty) ...[
        Text(l10n.customersLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        ...customers.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                title: Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                subtitle: Text(c.phone, style: TextStyle(color: AppColors.textMedium)),
                trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMedium),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: c))).then((_) => _fetchSummary()),
              ),
            )),
        const SizedBox(height: 12),
      ],
      if (orders.isNotEmpty) ...[
        Text(l10n.ordersLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        ...orders.map((o) {
          final statusColor = AppColors.statusColor(o.status);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
              border: Border(left: BorderSide(color: statusColor, width: 4)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
              ),
              title: Text(o.customerName ?? l10n.unknown, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
              subtitle: Text(o.clothingType, style: TextStyle(color: AppColors.textMedium)),
              trailing: Text(localizedStatus(l10n, o.status), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              onTap: () {
                final customer = _customerFor(o);
                if (customer != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer))).then((_) => _fetchSummary());
                }
              },
            ),
          );
        }),
      ],
    ];
  }

  List<Widget> _buildDashboardContent(AppLocalizations l10n) {
    return [
      // Quick Action Buttons
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

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.status,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Icon(Icons.analytics_outlined, color: AppColors.iconMuted, size: 20),
        ],
      ),
      const SizedBox(height: 16),

      // Stats Grid (Premium Cards)
      _buildStatsGrid(),
      const SizedBox(height: 32),

      Text(
        l10n.navigation,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      const SizedBox(height: 12),

      // Premium Navigation Cards
      _buildNavigationItem(
        context,
        l10n.totalCustomers,
        Icons.people_alt_rounded,
        Colors.blue.shade700,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())),
      ),
      const SizedBox(height: 12),
      _buildNavigationItem(
        context,
        l10n.totalOrders,
        Icons.receipt_long_rounded,
        const Color(0xFF5D4037),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen())),
      ),
      const SizedBox(height: 12),
      _buildNavigationItem(
        context,
        l10n.upcomingDeliveries,
        Icons.local_shipping_outlined,
        AppColors.statusInProgress,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpcomingDeliveriesScreen())),
      ),
      const SizedBox(height: 12),
      _buildNavigationItem(
        context,
        l10n.reports,
        Icons.bar_chart_rounded,
        AppColors.secondary,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
      ),
      const SizedBox(height: 12),
      _buildNavigationItem(
        context,
        l10n.expenses,
        Icons.account_balance_wallet_outlined,
        Colors.deepPurple,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen())),
      ),
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
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
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

  Widget _buildNavigationItem(
    BuildContext context,
    String label,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.iconMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
