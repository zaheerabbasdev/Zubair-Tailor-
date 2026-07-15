import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/expense.dart';
import '../models/order.dart';
import '../providers/theme_provider.dart';
import '../repositories/customer_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/order_repository.dart';
import '../utils/app_colors.dart';
import '../utils/status_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  final CustomerRepository _customerRepository = CustomerRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  List<Order> _orders = [];
  List<Expense> _expenses = [];
  int _totalCustomers = 0;
  bool _isLoading = true;
  String _range = 'Today';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final orders = await _orderRepository.getAll();
      final customers = await _customerRepository.getAll();
      final expenses = await _expenseRepository.getAll();
      if (mounted) {
        setState(() {
          _orders = orders;
          _expenses = expenses;
          _totalCustomers = customers.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime? _customStart;
  DateTime? _customEnd;

  DateTime? get _cutoffStart {
    final now = DateTime.now();
    switch (_range) {
      case 'Today': return DateTime(now.year, now.month, now.day);
      case 'This Week': return DateTime(now.year, now.month, now.day - (now.weekday - 1));
      case 'This Month': return DateTime(now.year, now.month, 1);
      case 'This Year': return DateTime(now.year, 1, 1);
      case 'Last Year': return DateTime(now.year - 1, 1, 1);
      case 'Custom': return _customStart;
      case 'All Time':
      default: return null;
    }
  }

  DateTime? get _cutoffEnd {
    final now = DateTime.now();
    switch (_range) {
      case 'Today': return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case 'This Week': return DateTime(now.year, now.month, now.day + (7 - now.weekday), 23, 59, 59);
      case 'This Month': return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case 'This Year': return DateTime(now.year, 12, 31, 23, 59, 59);
      case 'Last Year': return DateTime(now.year - 1, 12, 31, 23, 59, 59);
      case 'Custom': return _customEnd;
      case 'All Time':
      default: return null;
    }
  }

  List<Order> get _filteredOrders {
    final start = _cutoffStart;
    final end = _cutoffEnd;
    return _orders.where((o) {
      if (o.createdAt == null) return false;
      if (start != null && o.createdAt!.isBefore(start)) return false;
      if (end != null && o.createdAt!.isAfter(end)) return false;
      return true;
    }).toList();
  }

  List<Expense> get _filteredExpenses {
    final start = _cutoffStart;
    final end = _cutoffEnd;
    return _expenses.where((e) {
      if (start != null && e.expenseDate.isBefore(start)) return false;
      if (end != null && e.expenseDate.isAfter(end)) return false;
      return true;
    }).toList();
  }

  Future<void> _selectCustomRange() async {
    final initial = DateTimeRange(
      start: _customStart ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _customEnd ?? DateTime.now(),
    );
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: initial,
    );
    if (range != null) {
      setState(() {
        _customStart = range.start;
        _customEnd = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
        _range = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppColors.dark = context.watch<ThemeProvider>().isDark;
    final l10n = AppLocalizations.of(context)!;
    final orders = _filteredOrders;

    final expenses = _filteredExpenses;

    final revenue = orders.fold<double>(0, (sum, o) => sum + o.amountPaid);
    final outstanding = orders.fold<double>(0, (sum, o) {
      final due = o.price - o.amountPaid;
      return sum + (due > 0 ? due : 0);
    });
    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final netProfit = revenue - totalExpenses;

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
        title: Text(l10n.reports, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Today', 'This Week', 'This Month', 'This Year', 'Last Year', 'Custom'].map((r) {
                        final selected = _range == r;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(localizedRange(l10n, r), style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : AppColors.textDark, fontSize: 13)),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => _range = r);
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_range == 'Custom') ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectCustomRange,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _customStart != null && _customEnd != null
                                  ? "${_customStart!.toString().split(' ')[0]}  —  ${_customEnd!.toString().split(' ')[0]}"
                                  : "Select Date Range",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            const Icon(Icons.date_range_rounded, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: l10n.revenueCollected,
                          value: "Rs. ${revenue.toStringAsFixed(0)}",
                          icon: Icons.payments_outlined,
                          accentColor: AppColors.statusReady,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: l10n.outstanding,
                          value: "Rs. ${outstanding.toStringAsFixed(0)}",
                          icon: Icons.hourglass_bottom_rounded,
                          accentColor: AppColors.statusPending,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: l10n.totalExpenses,
                          value: "Rs. ${totalExpenses.toStringAsFixed(0)}",
                          icon: Icons.receipt_long_outlined,
                          accentColor: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: l10n.netProfit,
                          value: "Rs. ${netProfit.toStringAsFixed(0)}",
                          icon: Icons.trending_up_rounded,
                          accentColor: netProfit >= 0 ? AppColors.statusReady : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    title: l10n.totalCustomersAllTime,
                    value: "$_totalCustomers",
                    icon: Icons.people_outline_rounded,
                    accentColor: AppColors.primary,
                    fullWidth: true,
                  ),

                  const SizedBox(height: 32),
                  Text(l10n.ordersByStatus, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  _buildBarSection(
                    entries: statusCounts.entries.map((e) => MapEntry(e.key, e.value)).toList(),
                    maxValue: maxStatusCount,
                    colorFor: (label) => AppColors.statusColor(label),
                    labelFor: (label) => localizedStatus(l10n, label),
                  ),

                  const SizedBox(height: 32),
                  Text(l10n.ordersByClothingType, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  sortedTypes.isEmpty
                      ? Text(l10n.noOrdersInRange, style: TextStyle(color: AppColors.textMedium))
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
    String Function(String label)? labelFor,
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
                    Text(labelFor != null ? labelFor(e.key) : e.key, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
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
