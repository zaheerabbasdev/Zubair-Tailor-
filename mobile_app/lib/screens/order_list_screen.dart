import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../providers/backup_provider.dart';
import '../providers/theme_provider.dart';
import '../repositories/order_repository.dart';
import '../providers/shop_profile_provider.dart';
import '../services/invoice_service.dart';
import '../services/notification_service.dart';
import 'order_form_screen.dart';
import '../utils/app_colors.dart';
import '../utils/status_helper.dart';
import '../utils/whatsapp_helper.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final data = await _orderRepository.getAll();
      if (mounted) {
        setState(() {
          _orders = data;
          _applyFilter(_selectedFilter);
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

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      final query = _searchController.text.toLowerCase();
      
      _filteredOrders = _orders.where((o) {
        final matchesFilter = filter == 'All' || o.status == filter;
        if (!matchesFilter) return false;
        
        if (query.isEmpty) return true;
        
        final nameMatch = o.customerName?.toLowerCase().contains(query) ?? false;
        final phoneMatch = o.customerPhone?.toLowerCase().contains(query) ?? false;
        final orderNumMatch = o.orderNumber?.toLowerCase().contains(query) ?? false;
        
        return nameMatch || phoneMatch || orderNumMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    AppColors.dark = context.watch<ThemeProvider>().isDark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(l10n.totalOrders, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            height: 60,
            color: AppColors.surfaceCard,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: ['All', 'Pending', 'In Progress', 'Ready', 'Delivered'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      localizedStatus(l10n, filter),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _applyFilter(filter);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surfaceCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: (value) => _applyFilter(_selectedFilter),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child: _filteredOrders.isEmpty
                        ? _buildEmptyState(l10n)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              final statusColor = AppColors.statusColor(order.status);
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(color: statusColor, width: 5),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              order.imageUrl != null
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Image.file(
                                                        File(order.imageUrl!),
                                                        width: 44,
                                                        height: 44,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) => Container(
                                                          padding: const EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.primary.withOpacity(0.08),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: const Icon(Icons.image_not_supported_outlined, color: AppColors.primary),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary.withOpacity(0.08),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                                                    ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (order.orderNumber != null) ...[
                                                      Text(
                                                        order.orderNumber!,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors.primary,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                    ],
                                                    Row(
                                                      children: [
                                                        if (order.priority) ...[
                                                          const Icon(Icons.priority_high_rounded, color: AppColors.primary, size: 16),
                                                          const SizedBox(width: 2),
                                                        ],
                                                        Expanded(
                                                          child: Text(
                                                            order.customerName ?? l10n.unknown,
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                              color: AppColors.textDark,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.iconMuted),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            "${l10n.deliveryDate}: ${order.deliveryDate != null ? order.deliveryDate!.toString().split(' ')[0] : 'N/A'}",
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(color: AppColors.textMedium, fontSize: 12, fontWeight: FontWeight.w500),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Rs. ${order.price.toInt()}",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: AppColors.textDark,
                                                    ),
                                                  ),
                                                  if (order.price - order.amountPaid > 0) ...[
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        "${l10n.dueLabel}: Rs. ${(order.price - order.amountPaid).toInt()}",
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 8),
                                                  _buildStatusBadge(order.status, l10n),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(height: 1, color: AppColors.divider),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              if (order.customerPhone != null)
                                                TextButton.icon(
                                                  icon: const Icon(Icons.chat_rounded, size: 18, color: AppColors.primary),
                                                  label: Text(
                                                    l10n.whatsapp,
                                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                  onPressed: () => sendWhatsAppMessage(
                                                    context,
                                                    phone: order.customerPhone!,
                                                    message: buildOrderStatusMessage(
                                                      customerName: order.customerName ?? 'Customer',
                                                      clothingType: order.clothingType,
                                                      status: order.status,
                                                      shopName: context.read<ShopProfileProvider>().shopName,
                                                    ),
                                                  ),
                                                ),
                                              TextButton.icon(
                                                icon: const Icon(Icons.receipt_rounded, size: 18, color: AppColors.primary),
                                                label: Text(
                                                  l10n.invoice,
                                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                                onPressed: () => InvoiceService.generateAndShareInvoice(context, order),
                                              ),
                                              TextButton.icon(
                                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                                label: Text(
                                                  l10n.edit,
                                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                                onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => OrderFormScreen(order: order)),
                                                ).then((_) => _fetchOrders()),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(height: 1, color: AppColors.divider),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  _buildUpdateStatusDropdown(order, l10n),
                                                  if (order.status == 'Delivered') ...[
                                                    const SizedBox(height: 4),
                                                    _buildDeliveredAction(order, l10n),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderFormScreen())).then((_) => _fetchOrders()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: Text(
          l10n.newOrder,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.iconMuted),
              ),
              const SizedBox(height: 24),
              Text(
                _selectedFilter == 'All'
                    ? l10n.noOrdersFound
                    : l10n.noOrdersFoundFilter(localizedStatus(l10n, _selectedFilter)),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tapToCreateOrder,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    final color = AppColors.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        localizedStatus(l10n, status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }


  Future<void> _updateOrderStatusToNext(Order order, String nextStatus) async {
    await _orderRepository.updateStatus(order.id!, nextStatus);
    if (nextStatus == 'Delivered') {
      try {
        await NotificationService.instance.cancelDeliveryReminder(order.id!);
      } catch (_) {}
      
      // If there's due payment, automatically show payment dialog when moving to Delivered
      if (order.price - order.amountPaid > 0) {
        if (mounted) {
          _fetchOrders();
          _showPaymentDialog(order.copyWith(status: nextStatus)); // show dialog with updated order
          return; // Skip normal fetch below since dialog does it
        }
      }
    }
    if (mounted) {
      context.read<BackupProvider>().syncInBackground();
      _fetchOrders();
    }
  }

  void _showPaymentDialog(Order order) {
    final l10n = AppLocalizations.of(context)!;
    final due = order.price - order.amountPaid;
    final TextEditingController amountController = TextEditingController(text: due.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Payment', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Due: Rs. ${due.toInt()}', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.amountPaid,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusReady),
            onPressed: () async {
              final val = double.tryParse(amountController.text) ?? 0.0;
              final newPaid = order.amountPaid + val;
              final updatedOrder = order.copyWith(amountPaid: newPaid);
              await _orderRepository.update(updatedOrder);
              
              if (mounted) {
                context.read<BackupProvider>().syncInBackground();
                Navigator.pop(ctx);
                _fetchOrders();
              }
            },
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateStatusDropdown(Order order, AppLocalizations l10n) {
    if (order.status == 'Delivered') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.updateStatus,
            style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.grey.shade400, size: 20),
        ],
      );
    }

    String nextStatus = '';
    IconData nextIcon = Icons.help;
    Color nextColor = Colors.grey;
    if (order.status == 'Pending') {
      nextStatus = 'In Progress';
      nextIcon = Icons.play_arrow_rounded;
      nextColor = AppColors.statusInProgress;
    } else if (order.status == 'In Progress') {
      nextStatus = 'Ready';
      nextIcon = Icons.check_circle_outline;
      nextColor = Colors.amber.shade800;
    } else if (order.status == 'Ready') {
      nextStatus = 'Delivered';
      nextIcon = Icons.local_shipping_outlined;
      nextColor = Colors.green.shade800;
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.updateStatus,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 20),
        ],
      ),
      onSelected: (val) {
        if (val == nextStatus) {
          _updateOrderStatusToNext(order, nextStatus);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: nextStatus,
          child: Row(
            children: [
              Icon(nextIcon, color: nextColor, size: 18),
              const SizedBox(width: 8),
              Text(
                localizedStatus(l10n, nextStatus),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveredAction(Order order, AppLocalizations l10n) {
    final due = order.price - order.amountPaid;
    if (due > 0) {
      return TextButton.icon(
        icon: const Icon(Icons.payments_outlined, size: 18, color: AppColors.primary),
        label: Text(
          'Pay Due (Rs. ${due.toInt()})',
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        onPressed: () => _showPaymentDialog(order),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Fully Paid',
            style: TextStyle(color: AppColors.statusReady, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.verified_rounded, color: AppColors.statusReady, size: 18),
        ],
      );
    }
  }
}
