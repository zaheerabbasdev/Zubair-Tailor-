import '../db/database_helper.dart';
import '../models/customer.dart';

class CustomerHasActiveOrdersException implements Exception {
  @override
  String toString() => 'Cannot delete customer with active orders';
}

class CustomerRepository {
  Future<List<Customer>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('customers', orderBy: 'id ASC');
    return rows.map((r) => Customer.fromJson(r)).toList();
  }

  Future<Customer> add(Customer customer) async {
    final db = await DatabaseHelper.instance.database;
    return db.transaction((txn) async {
      final id = await txn.insert('customers', {
        // temporary unique placeholder until the real id is known, replaced below
        'unique_id': 'tmp_${DateTime.now().microsecondsSinceEpoch}',
        'name': customer.name,
        'phone': customer.phone,
        'address': customer.address,
      });
      final uniqueId = id.toString().padLeft(4, '0');
      await txn.update('customers', {'unique_id': uniqueId}, where: 'id = ?', whereArgs: [id]);
      return customer.copyWith(id: id, uniqueId: uniqueId);
    });
  }

  Future<void> update(Customer customer) async {
    final db = await DatabaseHelper.instance.database;
    final data = customer.toJson()
      ..remove('id')
      ..remove('unique_id');
    await db.update('customers', data, where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM orders WHERE customer_id = ? AND status != ?',
      [id, 'Delivered'],
    );
    final activeOrders = (result.first['count'] as int?) ?? 0;
    if (activeOrders > 0) {
      throw CustomerHasActiveOrdersException();
    }
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
