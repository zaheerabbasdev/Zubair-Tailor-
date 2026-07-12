import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../models/order.dart';
import '../providers/backup_provider.dart';
import '../providers/theme_provider.dart';
import '../repositories/customer_repository.dart';
import '../repositories/measurement_repository.dart';
import '../repositories/order_repository.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? order;
  const OrderFormScreen({super.key, this.order});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final MeasurementRepository _measurementRepository = MeasurementRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.order != null;

  Customer? _selectedCustomer;
  Measurement? _selectedMeasurement;
  List<Customer> _customers = [];
  List<Measurement> _measurements = [];

  late final TextEditingController _clothingTypeController;
  late final TextEditingController _priceController;
  late final TextEditingController _amountPaidController;
  late final TextEditingController _notesController;
  DateTime? _deliveryDate;
  bool _priority = false;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _clothingTypeController = TextEditingController(text: o?.clothingType ?? '');
    _priceController = TextEditingController(text: o != null ? o.price.toString() : '');
    _amountPaidController = TextEditingController(text: o != null && o.amountPaid > 0 ? o.amountPaid.toString() : '');
    _notesController = TextEditingController(text: o?.notes ?? '');
    _deliveryDate = o?.deliveryDate;
    _priority = o?.priority ?? false;
    _imagePath = o?.imageUrl;
    _fetchCustomers();
  }

  @override
  void dispose() {
    _clothingTypeController.dispose();
    _priceController.dispose();
    _amountPaidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomers() async {
    final data = await _customerRepository.getAll();
    setState(() {
      _customers = data;
    });

    final o = widget.order;
    if (o != null) {
      Customer? customer;
      for (final c in data) {
        if (c.id == o.customerId) {
          customer = c;
          break;
        }
      }
      if (customer != null) {
        setState(() => _selectedCustomer = customer);
        await _fetchMeasurements(customer.id!);
        Measurement? measurement;
        for (final m in _measurements) {
          if (m.id == o.measurementId) {
            measurement = m;
            break;
          }
        }
        if (measurement != null) {
          setState(() => _selectedMeasurement = measurement);
        }
      }
    }
  }

  Future<void> _fetchMeasurements(int customerId) async {
    final data = await _measurementRepository.getForCustomer(customerId);
    setState(() {
      _measurements = data;
    });
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: const Text("Take Photo"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text("Choose from Gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );

    if (source == null) {
      setState(() => _imagePath = null);
      return;
    }

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'order_photos'));
    if (!await photosDir.exists()) await photosDir.create(recursive: true);
    final destPath = p.join(photosDir.path, 'order_${DateTime.now().microsecondsSinceEpoch}.jpg');
    await File(picked.path).copy(destPath);

    setState(() => _imagePath = destPath);
  }

  @override
  Widget build(BuildContext context) {
    AppColors.dark = context.watch<ThemeProvider>().isDark;
    final l10n = AppLocalizations.of(context)!;
    final price = double.tryParse(_priceController.text) ?? 0;
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
    final overpaid = amountPaid > price && price > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(
          _isEditing ? "Edit Order" : l10n.newOrder,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Details / تفصیلات",
                        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),
                  DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: InputDecoration(
                      labelText: l10n.customerName,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    items: _customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCustomer = val;
                        _selectedMeasurement = null;
                      });
                      if (val != null) _fetchMeasurements(val.id!);
                    },
                    validator: (v) => v == null ? 'Please select a customer' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Measurement>(
                    value: _selectedMeasurement,
                    decoration: InputDecoration(
                      labelText: l10n.measurements,
                      prefixIcon: const Icon(Icons.architecture_rounded, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    items: _measurements.map((m) => DropdownMenuItem(value: m, child: Text("ID: ${m.id} (${m.createdAt?.split('T')[0] ?? ''})"))).toList(),
                    onChanged: (val) => setState(() => _selectedMeasurement = val),
                    validator: (v) => v == null ? 'Please select a measurement' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _clothingTypeController,
                    decoration: InputDecoration(
                      labelText: l10n.clothingType,
                      prefixIcon: const Icon(Icons.style_outlined, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter clothing type' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: l10n.price,
                            prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: (v) => v == null || v.isEmpty ? 'Please enter price' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _amountPaidController,
                          decoration: InputDecoration(
                            labelText: "Amount Paid",
                            prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  if (overpaid) ...[
                    const SizedBox(height: 6),
                    const Text(
                      "Amount paid is more than the price — please double-check.",
                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _deliveryDate ?? DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _deliveryDate = date);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.deliveryDate,
                        prefixIcon: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      child: Text(
                        _deliveryDate == null ? "Select Date" : _deliveryDate!.toString().split(' ')[0],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ChoiceChip(
                    label: const Text("Urgent", style: TextStyle(fontWeight: FontWeight.bold)),
                    avatar: Icon(Icons.priority_high_rounded, size: 18, color: _priority ? Colors.white : AppColors.primary),
                    selected: _priority,
                    onSelected: (v) => setState(() => _priority = v),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    labelStyle: TextStyle(color: _priority ? Colors.white : AppColors.textDark),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: _priority ? AppColors.primary : AppColors.divider),
                    showCheckmark: false,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10n.notes,
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _imagePath == null
                          ? Row(
                              children: [
                                const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Text("Add Reference Photo", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                              ],
                            )
                          : Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(_imagePath!),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text("Tap to change photo", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: AppColors.primary,
                shadowColor: AppColors.primary.withOpacity(0.4),
                elevation: 4,
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      l10n.save,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null || _selectedMeasurement == null) return;

    setState(() => _isSaving = true);

    final order = Order(
      id: widget.order?.id,
      customerId: _selectedCustomer!.id!,
      measurementId: _selectedMeasurement!.id!,
      clothingType: _clothingTypeController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      amountPaid: double.tryParse(_amountPaidController.text) ?? 0,
      priority: _priority,
      deliveryDate: _deliveryDate,
      status: widget.order?.status ?? 'Pending',
      notes: _notesController.text,
      imageUrl: _imagePath,
    );

    try {
      Order saved;
      if (_isEditing) {
        saved = await _orderRepository.update(order);
      } else {
        saved = await _orderRepository.create(order);
      }
      try {
        await NotificationService.instance.cancelDeliveryReminder(saved.id!);
        await NotificationService.instance.scheduleDeliveryReminder(saved);
      } catch (_) {
        // Reminder scheduling is best-effort and must never block saving the order.
      }
      if (mounted) {
        context.read<BackupProvider>().syncInBackground();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save order')),
        );
      }
    }
  }
}
