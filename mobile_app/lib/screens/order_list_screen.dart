import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import 'order_form_screen.dart';
import '../utils/app_colors.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final ApiService _apiService = ApiService();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await _apiService.getOrders();
      final List data = response.data;
      setState(() {
        _orders = data.map((e) => Order.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.totalOrders, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.customerName ?? "Unknown / نامعلوم",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(order.clothingType, style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text("${l10n.deliveryDate}: ${order.deliveryDate != null ? order.deliveryDate!.toString().split(' ')[0] : 'N/A'}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Rs. ${order.price}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                                  const SizedBox(height: 8),
                                  _buildStatusBadge(order.status, l10n),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.edit_outlined, size: 20, color: order.status == 'Delivered' ? Colors.grey : AppColors.primary),
                                label: Text(
                                  "Update Status / اسٹیٹس تبدیل کریں",
                                  style: TextStyle(color: order.status == 'Delivered' ? Colors.grey : AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                                onPressed: order.status == 'Delivered' ? null : () => _showStatusUpdateDialog(order),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderFormScreen())).then((_) => _fetchOrders()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.newOrder),
      ),
    );
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    Color color;
    switch (status) {
      case 'Pending': color = Colors.orange; break;
      case 'In Progress': color = Colors.blue; break;
      case 'Ready': color = Colors.green; break;
      case 'Delivered': color = Colors.grey; break;
      default: color = Colors.black;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  void _showStatusUpdateDialog(Order order) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.updateStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Pending', 'In Progress', 'Ready', 'Delivered'].map((s) => ListTile(
            title: Text(s),
            onTap: () async {
              await _apiService.updateOrderStatus(order.id!, s);
              if (mounted) {
                Navigator.pop(context);
                _fetchOrders();
              }
            },
          )).toList(),
        ),
      ),
    );
  }
}
