import '../db/database_helper.dart';
import '../models/measurement.dart';

class MeasurementRepository {
  Future<List<Measurement>> getForCustomer(int customerId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'measurements',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => Measurement.fromJson(r)).toList();
  }

  Future<Measurement> add(Measurement measurement) async {
    final db = await DatabaseHelper.instance.database;
    final createdAt = DateTime.now().toIso8601String();
    final data = measurement.toJson();
    data.remove('id');
    data['created_at'] = createdAt;
    final id = await db.insert('measurements', data);
    return measurement.copyWith(id: id, createdAt: createdAt);
  }

  Future<Measurement> update(int id, Measurement measurement) async {
    final db = await DatabaseHelper.instance.database;
    final data = measurement.toJson();
    data.remove('id');
    data.remove('created_at');
    await db.update('measurements', data, where: 'id = ?', whereArgs: [id]);
    return measurement.copyWith(id: id);
  }
}
