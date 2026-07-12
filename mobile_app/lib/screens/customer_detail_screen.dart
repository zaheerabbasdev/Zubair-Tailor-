import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../models/order.dart';
import '../providers/backup_provider.dart';
import '../providers/shop_profile_provider.dart';
import '../providers/theme_provider.dart';
import '../repositories/customer_repository.dart';
import '../repositories/measurement_repository.dart';
import '../repositories/order_repository.dart';
import '../services/invoice_service.dart';
import '../utils/status_helper.dart';
import '../utils/whatsapp_helper.dart';
import 'measurement_form_screen.dart';
import 'order_form_screen.dart';
import '../widgets/add_customer_sheet.dart';
import '../utils/app_colors.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final MeasurementRepository _measurementRepository = MeasurementRepository();
  final OrderRepository _orderRepository = OrderRepository();
  late Customer _customer;
  List<Measurement> _measurements = [];
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final measurements = await _measurementRepository.getForCustomer(_customer.id!);
      final orders = await _orderRepository.getForCustomer(_customer.id!);
      if (mounted) {
        setState(() {
          _measurements = measurements;
          _orders = orders;
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

  Future<void> _editCustomer() async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: AddCustomerSheet(customer: _customer),
      ),
    );

    if (result is Customer && mounted) {
      setState(() => _customer = result);
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
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(_customer.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: _editCustomer,
            tooltip: l10n.edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            onPressed: () => _showDeleteConfirmation(context, l10n),
            tooltip: l10n.delete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildCustomerInfoCard(l10n),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.measurements,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                      ),
                      TextButton.icon(
                        icon: Icon(
                          Icons.add_rounded,
                          color: _measurements.isEmpty ? AppColors.primary : Colors.grey,
                        ),
                        label: Text(
                          l10n.addMeasurement,
                          style: TextStyle(
                            color: _measurements.isEmpty ? AppColors.primary : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _measurements.isEmpty
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MeasurementFormScreen(customer: _customer),
                                  ),
                                ).then((_) => _fetchData())
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_measurements.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.architecture_rounded, size: 48, color: AppColors.iconMuted),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noMeasurementsFound,
                            style: TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._measurements.map((m) => _buildMeasurementCard(m, l10n)),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalOrders,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                      ),
                      Text(
                        "${_orders.length}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_orders.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.iconMuted),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noOrdersFound,
                            style: TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._orders.map((o) => _buildOrderCard(o, l10n)),
                ],
              ),
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(l10n.deleteConfirm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _customerRepository.delete(_customer.id!);
                if (mounted) {
                  context.read<BackupProvider>().syncInBackground();
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.deleteErrorOrders)),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _customer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "ID: ${_customer.uniqueId ?? '---'}",
                            style: const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _customer.phone,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_customer.address != null && _customer.address!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: Colors.white24, height: 1),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _customer.address!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_customer.notes != null && _customer.notes!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: Colors.white24, height: 1),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sticky_note_2_outlined, color: AppColors.accent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _customer.notes!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static final _compactActionButtonStyle = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  Widget _buildOrderCard(Order o, AppLocalizations l10n) {
    final statusColor = AppColors.statusColor(o.status);
    final due = o.price - o.amountPaid;

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
            border: Border(left: BorderSide(color: statusColor, width: 5)),
          ),
          child: Column(
            children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (o.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(o.imageUrl!),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.primary, size: 20),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
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
                      Row(
                        children: [
                          if (o.priority) ...[
                            const Icon(Icons.priority_high_rounded, color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              o.clothingType,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rs. ${o.price}",
                        style: TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w600),
                      ),
                      if (due > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${l10n.dueLabel}: Rs. $due",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
                  ),
                  child: Text(
                    localizedStatus(l10n, o.status),
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  style: _compactActionButtonStyle,
                  icon: const Icon(Icons.chat_rounded, size: 16, color: AppColors.primary),
                  label: Text(l10n.whatsapp, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => sendWhatsAppMessage(
                    context,
                    phone: _customer.phone,
                    message: buildOrderStatusMessage(
                      customerName: _customer.name,
                      clothingType: o.clothingType,
                      status: o.status,
                      shopName: context.read<ShopProfileProvider>().shopName,
                    ),
                  ),
                ),
                TextButton.icon(
                  style: _compactActionButtonStyle,
                  icon: const Icon(Icons.receipt_rounded, size: 16, color: AppColors.primary),
                  label: Text(l10n.invoice, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => InvoiceService.generateAndShareInvoice(context, o),
                ),
                TextButton.icon(
                  style: _compactActionButtonStyle,
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  label: Text(l10n.edit, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderFormScreen(order: o)),
                  ).then((_) => _fetchData()),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementCard(Measurement m, AppLocalizations l10n) {
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
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text(
              l10n.createdOn(m.createdAt != null ? m.createdAt!.split('T')[0] : l10n.na),
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.architecture_rounded, color: AppColors.primary, size: 20),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 16),
                    _buildSectionHeaderTitle(l10n.dimensions.toUpperCase()),
                    const SizedBox(height: 12),
                    _buildMeasurementRow(l10n.shirtLength, m.shirtLength, l10n.shirtWidth, m.shirtWidth),
                    _buildMeasurementRow(l10n.shoulder, m.shoulder, l10n.sleeve, m.sleeve),
                    _buildMeasurementRow(l10n.chest, m.chest, l10n.ghera, m.ghera),
                    _buildMeasurementRow(l10n.pancha, m.pancha, l10n.shalwarLength, m.shalwarLength),
                    _buildMeasurementRow(l10n.collar, m.collar, null, null),

                    const SizedBox(height: 20),
                    _buildSectionHeaderTitle(l10n.style.toUpperCase()),
                    const SizedBox(height: 12),
                    _buildMeasurementRow(l10n.banType, _getLocalizedValue(m.banType, l10n), l10n.damanType, _getLocalizedValue(m.damanType, l10n)),
                    _buildMeasurementRow(l10n.sleeveType, _getLocalizedValue(m.sleeveType, l10n), null, null),

                    const SizedBox(height: 20),
                    _buildSectionHeaderTitle(l10n.stitchingDetails.toUpperCase()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (m.frontPocket) _buildBadge(l10n.frontPocket),
                        if (m.pocketType != null && m.pocketType != 'none') _buildBadge("${l10n.sidePocket}: ${_getLocalizedValue(m.pocketType, l10n)}"),
                        if (m.shalwarPocket) _buildBadge(l10n.shalwarPocket),
                        if (m.ringButton) _buildBadge(l10n.ringButton),
                        if (m.doubleSilai) _buildBadge(l10n.doubleSilai),
                        if (m.chamakTar) _buildBadge(l10n.chamakTar),
                        if (m.sadaPatti) _buildBadge(l10n.sadaPatti),
                        if (m.designButton) _buildBadge(l10n.designButton),
                      ],
                    ),

                    if (m.notes != null && m.notes!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSectionHeaderTitle(l10n.notes.toUpperCase()),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          m.notes!,
                          style: TextStyle(color: AppColors.textDark, height: 1.4, fontSize: 13),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MeasurementFormScreen(customer: _customer, measurement: m),
                          ),
                        ).then((_) => _fetchData()),
                        icon: const Icon(Icons.edit_note_rounded, size: 22, color: Colors.white),
                        label: Text(
                          l10n.editMeasurement,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeaderTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        fontSize: 11,
        color: AppColors.primary,
      ),
    );
  }

  String _getLocalizedValue(String? value, AppLocalizations l10n) {
    if (value == null) return '-';
    switch (value) {
      case 'ban': return l10n.ban;
      case 'gol_ban': return l10n.golBan;
      case 'none': return l10n.none;
      case 'square': return l10n.square;
      case 'round': return l10n.round;
      case 'gol': return l10n.gol;
      case 'cuff': return l10n.cuff;
      case 'single': return l10n.single;
      case 'double': return l10n.double;
      default: return value;
    }
  }

  Widget _buildMeasurementRow(String l1, dynamic v1, String? l2, dynamic v2) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l1, style: TextStyle(fontSize: 11, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      v1?.toString() ?? '-',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (l2 != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l2, style: TextStyle(fontSize: 11, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        v2?.toString() ?? '-',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                        textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}
