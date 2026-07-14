import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../providers/theme_provider.dart';
import '../repositories/order_repository.dart';
import '../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  List<Order> _orders = [];
  Set<String> _readOrderIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadStatus();
    _fetchOrders();
  }
  
  Future<void> _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _readOrderIds = (prefs.getStringList('read_notifications') ?? []).toSet();
    });
  }
  
  Future<void> _markAsRead(Order o) async {
    if (o.id == null) return;
    final idStr = o.id.toString();
    if (!_readOrderIds.contains(idStr)) {
      final prefs = await SharedPreferences.getInstance();
      _readOrderIds.add(idStr);
      await prefs.setStringList('read_notifications', _readOrderIds.toList());
      setState(() {});
    }
  }

  DateTime _reminderTime(Order o) {
    final d = o.deliveryDate!.subtract(const Duration(days: 3));
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
  
  void _showNotificationModal(Order o, AppLocalizations l10n, bool sent, DateTime reminderTime) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            o.customerName ?? l10n.unknown,
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${l10n.clothingType}: ${o.clothingType}",
                style: TextStyle(color: AppColors.textDark, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                "Due for delivery on ${o.deliveryDate?.toString().split(' ')[0] ?? 'N/A'}",
                style: TextStyle(color: AppColors.textMedium, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Text(
                sent
                    ? l10n.reminderSent
                    : l10n.reminderScheduledFor(reminderTime.toString().split(' ')[0]),
                style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _markAsRead(o);
              },
              child: Text("Close", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    ).then((_) {
      _markAsRead(o);
    });
  }

  Widget _buildReminderCard(Order o, AppLocalizations l10n) {
    final reminderTime = _reminderTime(o);
    final sent = reminderTime.isBefore(DateTime.now());
    final isRead = _readOrderIds.contains(o.id.toString());
    
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
          onTap: () => _showNotificationModal(o, l10n, sent, reminderTime),
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
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold, 
                          fontStyle: isRead ? FontStyle.italic : FontStyle.normal,
                          fontSize: 16, 
                          color: AppColors.textDark
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        o.clothingType,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold, 
                          fontStyle: isRead ? FontStyle.italic : FontStyle.normal,
                          fontSize: 13, 
                          color: AppColors.primary
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sent
                            ? l10n.reminderSent
                            : l10n.reminderScheduledFor(reminderTime.toString().split(' ')[0]),
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold, 
                          fontStyle: isRead ? FontStyle.italic : FontStyle.normal,
                          fontSize: 12, 
                          color: accentColor
                        ),
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
