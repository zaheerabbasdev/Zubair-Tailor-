import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../providers/theme_provider.dart';
import '../repositories/order_repository.dart';
import 'order_form_screen.dart';
import '../utils/app_colors.dart';
import '../utils/status_helper.dart';

class UpcomingDeliveriesScreen extends StatefulWidget {
  const UpcomingDeliveriesScreen({super.key});

  @override
  State<UpcomingDeliveriesScreen> createState() => _UpcomingDeliveriesScreenState();
}

class _UpcomingDeliveriesScreenState extends State<UpcomingDeliveriesScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final data = await _orderRepository.getAll();
      final relevant = data.where((o) => o.deliveryDate != null && o.status != 'Delivered').toList()
        ..sort((a, b) => a.deliveryDate!.compareTo(b.deliveryDate!));
      if (mounted) {
        setState(() {
          _orders = relevant;
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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        title: Text(l10n.upcomingDeliveries, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: _orders.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) => _buildOrderCard(_orders[index], l10n),
                    ),
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle),
                child: Icon(Icons.event_available_rounded, size: 64, color: AppColors.iconMuted),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noUpcomingDeliveries,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.deliveryDateWillShow,
                style: TextStyle(fontSize: 14, color: AppColors.textMedium),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order o, AppLocalizations l10n) {
    final overdue = o.deliveryDate!.isBefore(DateTime.now());
    final accentColor = overdue ? Colors.red.shade600 : AppColors.statusColor(o.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderFormScreen(order: o)),
          ).then((_) => _fetchOrders()),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accentColor, width: 5)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    overdue ? Icons.warning_amber_rounded : Icons.local_shipping_outlined,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (o.priority) ...[
                            const Icon(Icons.priority_high_rounded, color: AppColors.primary, size: 16),
                            const SizedBox(width: 2),
                          ],
                          Expanded(
                            child: Text(
                              o.customerName ?? l10n.unknown,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        o.clothingType,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        overdue
                            ? l10n.overdueSince(o.deliveryDate!.toString().split(' ')[0])
                            : l10n.dueOn(o.deliveryDate!.toString().split(' ')[0]),
                        style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusColor(o.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    localizedStatus(l10n, o.status),
                    style: TextStyle(color: AppColors.statusColor(o.status), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
