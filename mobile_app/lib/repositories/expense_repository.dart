import '../db/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  Future<List<Expense>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('expenses', orderBy: 'expense_date DESC');
    return rows.map((r) => Expense.fromJson(r)).toList();
  }

  Future<Expense> add(Expense expense) async {
    final db = await DatabaseHelper.instance.database;
    final createdAt = DateTime.now().toIso8601String();
    final data = expense.toJson();
    data.remove('id');
    data['created_at'] = createdAt;
    final id = await db.insert('expenses', data);
    return expense.copyWith(id: id, createdAt: DateTime.parse(createdAt));
  }

  Future<void> update(Expense expense) async {
    final db = await DatabaseHelper.instance.database;
    final data = expense.toJson();
    data.remove('id');
    await db.update('expenses', data, where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
