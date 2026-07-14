import '../db/database_helper.dart';
import '../models/order.dart';

class OrderRepository {
  Future<List<Order>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT o.*, c.name AS customer_name, c.phone AS customer_phone
      FROM orders o
      JOIN customers c ON c.id = o.customer_id
      ORDER BY o.id DESC
    ''');
    return rows.map((r) => Order.fromJson(r)).toList();
  }

  Future<List<Order>> getForCustomer(int customerId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT o.*, c.name AS customer_name, c.phone AS customer_phone
      FROM orders o
      JOIN customers c ON c.id = o.customer_id
      WHERE o.customer_id = ?
      ORDER BY o.id DESC
    ''', [customerId]);
    return rows.map((r) => Order.fromJson(r)).toList();
  }

  Future<Order> create(Order order) async {
    final db = await DatabaseHelper.instance.database;
    final data = order.toJson();
    data.remove('id');
    data.remove('order_number');
    data['status'] = 'Pending';
    final now = DateTime.now();
    data['created_at'] = now.toIso8601String();
    
    final id = await db.insert('orders', data);
    
    // Generate order number with format ORD-YYYYMMDD-ID
    final dateStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final orderNumber = "ORD-$dateStr-$id";
    
    await db.update('orders', {'order_number': orderNumber}, where: 'id = ?', whereArgs: [id]);
    
    return order.copyWith(id: id, status: 'Pending', orderNumber: orderNumber);
  }

  Future<Order> update(Order order) async {
    final db = await DatabaseHelper.instance.database;
    final data = order.toJson();
    data.remove('id');
    await db.update('orders', data, where: 'id = ?', whereArgs: [order.id]);
    return order;
  }

  Future<Order> updateStatus(int orderId, String status) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('orders', {'status': status}, where: 'id = ?', whereArgs: [orderId]);
    final rows = await db.rawQuery('''
      SELECT o.*, c.name AS customer_name, c.phone AS customer_phone
      FROM orders o
      JOIN customers c ON c.id = o.customer_id
      WHERE o.id = ?
    ''', [orderId]);
    return Order.fromJson(rows.first);
  }
}
