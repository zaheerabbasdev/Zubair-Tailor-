import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import 'customer_detail_screen.dart';
import '../widgets/add_customer_sheet.dart';
import '../utils/app_colors.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final ApiService _apiService = ApiService();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      final response = await _apiService.getCustomers();
      final List data = response.data;
      setState(() {
        _customers = data.map((e) => Customer.fromJson(e)).toList();
        _filteredCustomers = _customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers = _customers
          .where((c) => 
            c.name.toLowerCase().contains(query.toLowerCase()) || 
            c.phone.contains(query) ||
            (c.uniqueId != null && c.uniqueId!.contains(query))
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.totalCustomers, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _filterCustomers,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchCustomers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.person, color: AppColors.primary),
                            ),
                            title: Row(
                              children: [
                                if (customer.uniqueId != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)),
                                    child: Text("#${customer.uniqueId}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                Expanded(child: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                              ],
                            ),
                            subtitle: Text(customer.phone, style: TextStyle(color: Colors.grey.shade600)),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerDetailScreen(customer: customer),
                                ),
                              ).then((_) => _fetchCustomers());
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addCustomer),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: AddCustomerSheet(),
      ),
    );

    if (result == true) {
      _fetchCustomers();
    }
  }
}
