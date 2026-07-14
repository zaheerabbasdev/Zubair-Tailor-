import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../providers/theme_provider.dart';
import '../repositories/order_repository.dart';
import 'order_form_screen.dart';
import '../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  DateTime _reminderTime(Order o) {
    final d = o.deliveryDate!.subtract(const Duration(days: 1));
    return DateTime(d.year, d.month, d.day, 9, 0);
  }

  Future<void> _fetchOrders() async {
    try {
      final data = await _orderRepository.getAll();
      final relevant = data.where((o) => o.deliveryDate != null && o.status != 'Delivered').toList()
        ..sort((a, b) => _reminderTime(a).compareTo(_reminderTime(b)));
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
        title: Text(l10n.notifications, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                      itemBuilder: (context, index) => _buildReminderCard(_orders[index], l10n),
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
                child: Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.iconMuted),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noNotifications,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.notificationsWillShow,
                style: TextStyle(fontSize: 14, color: AppColors.textMedium),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(Order o, AppLocalizations l10n) {
    final reminderTime = _reminderTime(o);
    final sent = reminderTime.isBefore(DateTime.now());
    final accentColor = sent ? AppColors.textMedium : AppColors.accent;

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
                    sent ? Icons.notifications_active_rounded : Icons.notifications_outlined,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.customerName ?? l10n.unknown,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
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
                        sent
                            ? l10n.reminderSent
                            : l10n.reminderScheduledFor(reminderTime.toString().split(' ')[0]),
                        style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
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
