import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../services/api_service.dart';
import 'measurement_form_screen.dart';
import '../utils/app_colors.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final ApiService _apiService = ApiService();
  List<Measurement> _measurements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMeasurements();
  }

  Future<void> _fetchMeasurements() async {
    try {
      final response = await _apiService.getMeasurements(widget.customer.id!);
      final List data = response.data;
      setState(() {
        _measurements = data.map((e) => Measurement.fromJson(e)).toList();
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
      appBar: AppBar(
        title: Text(widget.customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context, l10n),
            tooltip: l10n.delete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchMeasurements,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildCustomerInfoCard(l10n),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.measurements, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: Icon(Icons.add, color: _measurements.isEmpty ? AppColors.primary : Colors.grey),
                        label: Text(l10n.addMeasurement, style: TextStyle(color: _measurements.isEmpty ? AppColors.primary : Colors.grey)),
                        onPressed: _measurements.isEmpty 
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MeasurementFormScreen(customer: widget.customer),
                              ),
                            ).then((_) => _fetchMeasurements())
                          : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_measurements.isEmpty)
                    Center(child: Padding(padding: const EdgeInsets.all(32), child: Text("No measurements found / کوئی ناپ نہیں ملا", style: TextStyle(color: Colors.grey.shade600)))),
                  ..._measurements.map((m) => _buildMeasurementCard(m, l10n)),
                ],
              ),
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.deleteCustomer(widget.customer.id!);
                if (mounted) {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.customer.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text("ID: ${widget.customer.uniqueId ?? '---'}", style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 12),
                        Text(widget.customer.phone, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementCard(Measurement m, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ExpansionTile(
            initiallyExpanded: false,
            title: Text("Date: ${m.createdAt != null ? m.createdAt!.split('T')[0] : 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.architecture, color: AppColors.primary),
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DIMENSIONS", style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    _buildMeasurementRow(l10n.shirtLength, m.shirtLength, l10n.shirtWidth, m.shirtWidth),
                    _buildMeasurementRow(l10n.shoulder, m.shoulder, l10n.sleeve, m.sleeve),
                    _buildMeasurementRow(l10n.chest, m.chest, l10n.ghera, m.ghera),
                    _buildMeasurementRow(l10n.pancha, m.pancha, l10n.shalwarLength, m.shalwarLength),
                    _buildMeasurementRow(l10n.collar, m.collar, null, null),

                    const Divider(height: 32),
                    const Text("STYLE", style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    _buildMeasurementRow(l10n.banType, m.banType, l10n.damanType, m.damanType),
                    _buildMeasurementRow(l10n.sleeveType, m.sleeveType, null, null),

                    const Divider(height: 32),
                    const Text("DETAILS", style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (m.frontPocket) _buildBadge(l10n.frontPocket),
                        if (m.sidePocket) _buildBadge(l10n.sidePocket),
                        if (m.cuff) _buildBadge(l10n.cuff),
                        if (m.shalwarPocket) _buildBadge(l10n.shalwarPocket),
                        if (m.ringButton) _buildBadge(l10n.ringButton),
                        if (m.doubleSilai) _buildBadge(l10n.doubleSilai),
                        if (m.chamakTar) _buildBadge(l10n.chamakTar),
                        if (m.sadaPatti) _buildBadge(l10n.sadaPatti),
                        if (m.designButton) _buildBadge(l10n.designButton),
                      ],
                    ),

                    if (m.notes != null && m.notes!.isNotEmpty) ...[
                      const Divider(height: 32),
                      Text("${l10n.notes}:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(m.notes!, style: TextStyle(color: Colors.grey.shade700)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MeasurementFormScreen(customer: widget.customer, measurement: m),
                          ),
                        ).then((_) => _fetchMeasurements()),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text("Edit Measurement / ناپ تبدیل کریں"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E2723),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(String l1, dynamic v1, String? l2, dynamic v2) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final alignment = isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.start; 
    // Actually standard is start. But for numbers we want LTR.
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l1, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    v1?.toString() ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left, 
                  ),
                ),
              ],
            ),
          ),
          if (l2 != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l2, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      v2?.toString() ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF3E2723).withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF3E2723).withOpacity(0.2))),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
    );
  }
}
