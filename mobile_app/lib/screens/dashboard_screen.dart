import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'customer_list_screen.dart';
import 'order_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final response = await _apiService.getDashboardSummary();
      setState(() {
        _summary = response.data;
        _isLoading = false;
      });
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
    final l10n = AppLocalizations.of(context)!;
    // Auth and Locale providers removed from here as they are now used in AppDrawer

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.appName, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        // Actions removed
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSummary,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  // Core Actions - Highly Visible
                  Row(
                    children: [
                      Expanded(
                        child: _buildSimpleButton(
                          context, 
                          l10n.addCustomer, 
                          Icons.person_add_rounded, 
                          AppColors.primary, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerListScreen())).then((_) => _fetchSummary())
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSimpleButton(
                          context, 
                          l10n.newOrder, 
                          Icons.add_task_rounded, 
                          AppColors.accent, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderListScreen())).then((_) => _fetchSummary())
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(l10n.status, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Status Summary Cards
                  _buildSummaryRow(
                    _buildCompactCard(l10n.totalCustomers, _summary?['total_customers']?.toString() ?? '0', Colors.blue.shade800, Icons.people_outline),
                    _buildCompactCard(l10n.totalOrders, _summary?['total_orders']?.toString() ?? '0', const Color(0xFF3E2723), Icons.inventory_2_outlined),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    _buildCompactCard(l10n.pendingOrders, _summary?['pending_orders']?.toString() ?? '0', Colors.orange.shade800, Icons.pending_actions),
                    _buildCompactCard(l10n.readyOrders, _summary?['ready_orders']?.toString() ?? '0', Colors.green.shade800, Icons.done_all),
                  ),
                  
                  const SizedBox(height: 40),
                  // Secondary Navigation
                  _buildNavItem(context, l10n.totalCustomers, Icons.person_search_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerListScreen()))),
                  const SizedBox(height: 12),
                  _buildNavItem(context, l10n.totalOrders, Icons.history_edu_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderListScreen()))),
                ],
              ),
            ),
    );
  }

  Widget _buildSimpleButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }

  Widget _buildSummaryRow(Widget c1, Widget c2) {
    return Row(children: [Expanded(child: c1), const SizedBox(width: 12), Expanded(child: c2)]);
  }

  Widget _buildCompactCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF3E2723).withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_forward_ios, color: Color(0xFF3E2723), size: 16)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Icon(icon, color: Colors.grey.shade400),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
