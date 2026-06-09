import '../core/database/database_service.dart';
import '../models/vehicle.dart';

class VehicleService {
  static Future<List<Vehicle>> getVehicles({String? status, String? search}) async {
    final db = await DatabaseService.db;
    String where = '';
    List<dynamic> whereArgs = [];

    if (status != null && status != 'all') {
      where = 'status = ?';
      whereArgs.add(status);
    }
    if (search != null && search.isNotEmpty) {
      final s = '%$search%';
      final searchClause =
          '(brand LIKE ? OR model LIKE ? OR color LIKE ? OR vin LIKE ? OR stock_number LIKE ?)';
      if (where.isEmpty) {
        where = searchClause;
      } else {
        where = '$where AND $searchClause';
      }
      whereArgs.addAll([s, s, s, s, s]);
    }

    final rows = await db.query(
      'vehicles',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'id DESC',
    );
    return rows.map(Vehicle.fromMap).toList();
  }

  static Future<Vehicle?> getVehicle(int id) async {
    final db = await DatabaseService.db;
    final rows = await db.query('vehicles', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Vehicle.fromMap(rows.first);
  }

  static Future<int> addVehicle(Vehicle v) async {
    final db = await DatabaseService.db;
    return db.insert('vehicles', v.toMap()..remove('id'));
  }

  static Future<void> updateVehicle(Vehicle v) async {
    final db = await DatabaseService.db;
    await db.update('vehicles', v.toMap(), where: 'id = ?', whereArgs: [v.id]);
  }

  static Future<void> updateStatus(int id, String status) async {
    final db = await DatabaseService.db;
    await db.update('vehicles', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteVehicle(int id) async {
    final db = await DatabaseService.db;
    await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, int>> getStatusCounts() async {
    final db = await DatabaseService.db;
    final rows = await db.rawQuery(
        'SELECT status, COUNT(*) as cnt FROM vehicles GROUP BY status');
    Map<String, int> result = {
      'available': 0,
      'reserved': 0,
      'sold': 0,
      'preparation': 0,
    };
    for (final row in rows) {
      result[row['status'] as String] = row['cnt'] as int;
    }
    return result;
  }

  static Future<int> getTotalCount() async {
    final db = await DatabaseService.db;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM vehicles');
    return (result.first['cnt'] as int?) ?? 0;
  }
}
