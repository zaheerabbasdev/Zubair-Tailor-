import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../models/order.dart';
import '../providers/backup_provider.dart';
import '../repositories/customer_repository.dart';
import '../repositories/measurement_repository.dart';
import '../repositories/order_repository.dart';
import '../utils/app_colors.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final MeasurementRepository _measurementRepository = MeasurementRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _formKey = GlobalKey<FormState>();

  Customer? _selectedCustomer;
  Measurement? _selectedMeasurement;
  List<Customer> _customers = [];
  List<Measurement> _measurements = [];

  final _clothingTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _deliveryDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final data = await _customerRepository.getAll();
    setState(() {
      _customers = data;
    });
  }

  Future<void> _fetchMeasurements(int customerId) async {
    final data = await _measurementRepository.getForCustomer(customerId);
    setState(() {
      _measurements = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(l10n.newOrder, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                color: Colors.white,
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
                      const Text(
                        "Details / تفصیلات",
                        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: Color(0xFFEEEEEE), height: 1),
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
                  TextFormField(
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
                    validator: (v) => v == null || v.isEmpty ? 'Please enter price' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
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
      customerId: _selectedCustomer!.id!,
      measurementId: _selectedMeasurement!.id!,
      clothingType: _clothingTypeController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      deliveryDate: _deliveryDate,
      status: 'Pending',
      notes: _notesController.text,
    );

    try {
      await _orderRepository.create(order);
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
