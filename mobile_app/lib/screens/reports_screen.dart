import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/theme_provider.dart';
import '../repositories/customer_repository.dart';
import '../repositories/order_repository.dart';
import '../utils/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  final CustomerRepository _customerRepository = CustomerRepository();

  List<Order> _orders = [];
  int _totalCustomers = 0;
  bool _isLoading = true;
  String _range = 'This Month';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final orders = await _orderRepository.getAll();
      final customers = await _customerRepository.getAll();
      if (mounted) {
        setState(() {
          _orders = orders;
          _totalCustomers = customers.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Order> get _filteredOrders {
    if (_range == 'All Time') return _orders;
    final now = DateTime.now();
    final cutoff = _range == 'This Month'
        ? DateTime(now.year, now.month, 1)
        : now.subtract(const Duration(days: 30));
    return _orders.where((o) => o.createdAt != null && o.createdAt!.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    AppColors.dark = context.watch<ThemeProvider>().isDark;
    final orders = _filteredOrders;

    final revenue = orders.fold<double>(0, (sum, o) => sum + o.amountPaid);
    final outstanding = orders.fold<double>(0, (sum, o) {
      final due = o.price - o.amountPaid;
      return sum + (due > 0 ? due : 0);
    });

    final statusCounts = <String, int>{'Pending': 0, 'In Progress': 0, 'Ready': 0, 'Delivered': 0};
    for (final o in orders) {
      statusCounts[o.status] = (statusCounts[o.status] ?? 0) + 1;
    }

    final typeCounts = <String, int>{};
    for (final o in orders) {
      typeCounts[o.clothingType] = (typeCounts[o.clothingType] ?? 0) + 1;
    }
    final sortedTypes = typeCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final maxStatusCount = statusCounts.values.fold(0, (m, v) => v > m ? v : m);
    final maxTypeCount = sortedTypes.isEmpty ? 0 : sortedTypes.first.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        title: const Text("Reports", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Wrap(
                    spacing: 8,
                    children: ['This Month', 'Last 30 Days', 'All Time'].map((r) {
                      final selected = _range == r;
                      return ChoiceChip(
                        label: Text(r, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : AppColors.textDark, fontSize: 13)),
                        selected: selected,
                        onSelected: (_) => setState(() => _range = r),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceCard,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: "Revenue Collected",
                          value: "Rs. ${revenue.toStringAsFixed(0)}",
                          icon: Icons.payments_outlined,
                          accentColor: AppColors.statusReady,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: "Outstanding",
                          value: "Rs. ${outstanding.toStringAsFixed(0)}",
                          icon: Icons.hourglass_bottom_rounded,
                          accentColor: AppColors.statusPending,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    title: "Total Customers (All Time)",
                    value: "$_totalCustomers",
                    icon: Icons.people_outline_rounded,
                    accentColor: AppColors.primary,
                    fullWidth: true,
                  ),

                  const SizedBox(height: 32),
                  Text("Orders by Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  _buildBarSection(
                    entries: statusCounts.entries.map((e) => MapEntry(e.key, e.value)).toList(),
                    maxValue: maxStatusCount,
                    colorFor: (label) => AppColors.statusColor(label),
                  ),

                  const SizedBox(height: 32),
                  Text("Orders by Clothing Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  sortedTypes.isEmpty
                      ? Text("No orders in this range", style: TextStyle(color: AppColors.textMedium))
                      : _buildBarSection(
                          entries: sortedTypes.map((e) => MapEntry(e.key, e.value)).toList(),
                          maxValue: maxTypeCount,
                          colorFor: (_) => AppColors.primary,
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accentColor, width: 4)),
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
                    decoration: BoxDecoration(color: accentColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium), maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarSection({
    required List<MapEntry<String, int>> entries,
    required int maxValue,
    required Color Function(String label) colorFor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: entries.map((e) {
          final fraction = maxValue == 0 ? 0.0 : e.value / maxValue;
          final color = colorFor(e.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    Text("${e.value}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: AppColors.divider,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
