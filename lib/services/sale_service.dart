import '../core/database/database_service.dart';
import '../models/sale.dart';

class SaleService {
  static Future<List<Sale>> getSales({String? status, String? search}) async {
    final db = await DatabaseService.db;

    final rows = await db.rawQuery('''
      SELECT s.*,
        (v.brand || ' ' || v.model) as vehicle_display,
        c.full_name as client_display
      FROM sales s
      LEFT JOIN vehicles v ON s.vehicle_id = v.id
      LEFT JOIN clients c ON s.client_id = c.id
      ORDER BY s.id DESC
    ''');

    var sales = rows.map(Sale.fromMap).toList();

    if (status != null && status != 'all') {
      sales = sales.where((s) => s.status == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      sales = sales
          .where((s) =>
              (s.vehicleDisplay ?? '').toLowerCase().contains(q) ||
              (s.clientDisplay ?? '').toLowerCase().contains(q))
          .toList();
    }
    return sales;
  }

  static Future<int> addSale(Sale s) async {
    final db = await DatabaseService.db;
    return db.insert('sales', s.toMap()..remove('id'));
  }

  static Future<void> updateSale(Sale s) async {
    final db = await DatabaseService.db;
    await db.update('sales', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
  }

  static Future<void> deleteSale(int id) async {
    final db = await DatabaseService.db;
    await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, double>> getMonthlyStats() async {
    final db = await DatabaseService.db;
    final now = DateTime.now();
    final monthStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final rows = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        COALESCE(SUM(total_price), 0) as revenue,
        COALESCE(SUM(total_price - paid_amount), 0) as pending
      FROM sales
      WHERE sale_date LIKE '$monthStr%' AND status != 'cancelled'
    ''');

    if (rows.isEmpty) return {'count': 0, 'revenue': 0, 'pending': 0};
    final row = rows.first;
    return {
      'count': (row['count'] as int? ?? 0).toDouble(),
      'revenue': (row['revenue'] as num? ?? 0).toDouble(),
      'pending': (row['pending'] as num? ?? 0).toDouble(),
    };
  }

  static Future<double> getTotalRevenue() async {
    final db = await DatabaseService.db;
    final rows = await db.rawQuery(
        "SELECT COALESCE(SUM(total_price),0) as total FROM sales WHERE status != 'cancelled'");
    return (rows.first['total'] as num? ?? 0).toDouble();
  }
}
