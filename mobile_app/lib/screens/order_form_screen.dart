import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../services/api_service.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  Customer? _selectedCustomer;
  Measurement? _selectedMeasurement;
  List<Customer> _customers = [];
  List<Measurement> _measurements = [];

  final _clothingTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _deliveryDate;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final response = await _apiService.getCustomers();
    final List data = response.data;
    setState(() {
      _customers = data.map((e) => Customer.fromJson(e)).toList();
    });
  }

  Future<void> _fetchMeasurements(int customerId) async {
    final response = await _apiService.getMeasurements(customerId);
    final List data = response.data;
    setState(() {
      _measurements = data.map((e) => Measurement.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text(l10n.newOrder, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Details / تفصیلات", style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: InputDecoration(labelText: l10n.customerName, prefixIcon: const Icon(Icons.person_outline)),
                    items: _customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCustomer = val;
                        _selectedMeasurement = null;
                      });
                      if (val != null) _fetchMeasurements(val.id!);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Measurement>(
                    value: _selectedMeasurement,
                    decoration: InputDecoration(labelText: l10n.measurements, prefixIcon: const Icon(Icons.architecture)),
                    items: _measurements.map((m) => DropdownMenuItem(value: m, child: Text("ID: ${m.id} (${m.createdAt?.split('T')[0] ?? ''})"))).toList(),
                    onChanged: (val) => setState(() => _selectedMeasurement = val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _clothingTypeController,
                    decoration: InputDecoration(labelText: l10n.clothingType, prefixIcon: const Icon(Icons.style_outlined)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: l10n.price, prefixIcon: const Icon(Icons.payments_outlined)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _deliveryDate = date);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l10n.deliveryDate, prefixIcon: const Icon(Icons.calendar_month_outlined)),
                      child: Text(_deliveryDate == null ? "Select Date" : _deliveryDate!.toString().split(' ')[0]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              child: Text(l10n.save, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_selectedCustomer == null || _selectedMeasurement == null) return;

    final Map<String, dynamic> data = {
      'customer_id': _selectedCustomer!.id,
      'measurement_id': _selectedMeasurement!.id,
      'clothing_type': _clothingTypeController.text,
      'price': _priceController.text,
      'delivery_date': _deliveryDate?.toIso8601String(),
      'notes': _notesController.text,
    };

    await _apiService.createOrder(data);
    if (mounted) Navigator.pop(context);
  }
}
