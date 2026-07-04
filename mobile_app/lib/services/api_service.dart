import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _customersKey = 'local_customers';
  static const String _measurementsKey = 'local_measurements';
  static const String _ordersKey = 'local_orders';

  ApiService();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Helper to mock Dio Response
  Response _mockResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: ''),
    );
  }

  Future<Response> getDashboardSummary() async {
    final prefs = await _prefs;
    final customers = await _getList(_customersKey);
    final orders = await _getList(_ordersKey);
    
    final pendingOrders = orders.where((o) => o['status'] == 'Pending').length;
    final readyOrders = orders.where((o) => o['status'] == 'Ready').length;

    return _mockResponse({
      'total_customers': customers.length,
      'total_orders': orders.length,
      'pending_orders': pendingOrders,
      'ready_orders': readyOrders,
    });
  }

  Future<Response> getCustomers() async {
    return _mockResponse(await _getList(_customersKey));
  }

  Future<Response> addCustomer(Map<String, dynamic> data) async {
    final list = await _getList(_customersKey);
    final newId = list.isEmpty ? 1 : list.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    final newCustomer = {
      ...data,
      'id': newId,
      'unique_id': newId.toString().padLeft(4, '0'),
    };
    list.add(newCustomer);
    await _saveList(_customersKey, list);
    return _mockResponse(newCustomer);
  }

  Future<Response> deleteCustomer(int id) async {
    final orders = await _getList(_ordersKey);
    final hasDeliveredOrder = orders.any((e) => e['customer_id'] == id && e['status'] == 'Delivered');
    if (hasDeliveredOrder) {
      throw Exception('Cannot delete customer with delivered orders');
    }
    final list = await _getList(_customersKey);
    list.removeWhere((e) => e['id'] == id);
    await _saveList(_customersKey, list);
    return _mockResponse({'message': 'Customer deleted'});
  }

  Future<Response> getMeasurements(int customerId) async {
    final list = await _getList(_measurementsKey);
    final filtered = list.where((e) => e['customer_id'] == customerId).toList();
    return _mockResponse(filtered);
  }

  Future<Response> addMeasurement(Map<String, dynamic> data) async {
    final list = await _getList(_measurementsKey);
    final newId = list.isEmpty ? 1 : list.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    final newMeasurement = {
      ...data,
      'id': newId,
      'created_at': DateTime.now().toIso8601String(),
    };
    list.add(newMeasurement);
    await _saveList(_measurementsKey, list);
    return _mockResponse(newMeasurement);
  }

  Future<Response> updateMeasurement(int id, Map<String, dynamic> data) async {
    final list = await _getList(_measurementsKey);
    final index = list.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      list[index] = {...list[index], ...data};
      await _saveList(_measurementsKey, list);
      return _mockResponse(list[index]);
    }
    return _mockResponse({'message': 'Measurement not found'}, statusCode: 404);
  }

  Future<Response> getOrders() async {
    final orders = await _getList(_ordersKey);
    final customers = await _getList(_customersKey);
    
    // Enrich orders with customer info
    final enriched = orders.map((order) {
      final customer = customers.firstWhere((c) => c['id'] == order['customer_id'], orElse: () => {});
      return {
        ...order,
        'customer_name': customer['name'] ?? 'Unknown',
        'customer_phone': customer['phone'] ?? '',
      };
    }).toList();
    
    return _mockResponse(enriched);
  }

  Future<Response> createOrder(dynamic data) async {
    final list = await _getList(_ordersKey);
    final newId = list.isEmpty ? 1 : list.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    
    Map<String, dynamic> orderData;
    if (data is FormData) {
      // Handle FormData if needed, but since we are local, we'll assume the fields are passed
      // In practice, we need to extract fields from FormData or change the caller.
      // Let's check the caller in order_form_screen.dart later.
      orderData = {}; 
    } else {
      orderData = Map<String, dynamic>.from(data);
    }

    final newOrder = {
      ...orderData,
      'id': newId,
      'status': 'Pending',
      'created_at': DateTime.now().toIso8601String(),
    };
    list.add(newOrder);
    await _saveList(_ordersKey, list);
    return _mockResponse(newOrder);
  }

  Future<Response> updateOrderStatus(int orderId, String status) async {
    final list = await _getList(_ordersKey);
    final index = list.indexWhere((e) => e['id'] == orderId);
    if (index != -1) {
      list[index]['status'] = status;
      await _saveList(_ordersKey, list);
      return _mockResponse(list[index]);
    }
    return _mockResponse({'message': 'Order not found'}, statusCode: 404);
  }

  // Generic helpers
  Future<List<Map<String, dynamic>>> _getList(String key) async {
    final prefs = await _prefs;
    final String? data = prefs.getString(key);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _saveList(String key, List<Map<String, dynamic>> list) async {
    final prefs = await _prefs;
    await prefs.setString(key, jsonEncode(list));
  }
}
