import '../core/database/database_service.dart';
import '../models/expense.dart';

class ExpenseService {
  static Future<List<Expense>> getExpenses({int? vehicleId}) async {
    final db = await DatabaseService.db;
    final rows = await db.rawQuery('''
      SELECT e.*,
        CASE WHEN v.id IS NOT NULL THEN (v.brand || ' ' || v.model) ELSE NULL END as vehicle_display
      FROM expenses e
      LEFT JOIN vehicles v ON e.vehicle_id = v.id
      ${vehicleId != null ? 'WHERE e.vehicle_id = $vehicleId' : ''}
      ORDER BY e.id DESC
    ''');
    return rows.map(Expense.fromMap).toList();
  }

  static Future<int> addExpense(Expense e) async {
    final db = await DatabaseService.db;
    return db.insert('expenses', e.toMap()..remove('id'));
  }

  static Future<void> updateExpense(Expense e) async {
    final db = await DatabaseService.db;
    await db.update('expenses', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  static Future<void> deleteExpense(int id) async {
    final db = await DatabaseService.db;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  static Future<double> getTotalExpenses({int? vehicleId}) async {
    final db = await DatabaseService.db;
    final where = vehicleId != null ? 'WHERE vehicle_id = $vehicleId' : '';
    final rows = await db
        .rawQuery('SELECT COALESCE(SUM(amount),0) as total FROM expenses $where');
    return (rows.first['total'] as num? ?? 0).toDouble();
  }
}
