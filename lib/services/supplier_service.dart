import '../core/database/database_service.dart';
import '../models/supplier.dart';

class SupplierService {
  static Future<List<Supplier>> getSuppliers({String? search}) async {
    final db = await DatabaseService.db;
    String? where;
    List<dynamic>? whereArgs;
    if (search != null && search.isNotEmpty) {
      final s = '%$search%';
      where = 'name LIKE ? OR phone LIKE ? OR wilaya LIKE ?';
      whereArgs = [s, s, s];
    }
    final rows = await db.query('suppliers',
        where: where, whereArgs: whereArgs, orderBy: 'id DESC');
    return rows.map(Supplier.fromMap).toList();
  }

  static Future<int> addSupplier(Supplier s) async {
    final db = await DatabaseService.db;
    return db.insert('suppliers', s.toMap()..remove('id'));
  }

  static Future<void> updateSupplier(Supplier s) async {
    final db = await DatabaseService.db;
    await db.update('suppliers', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
  }

  static Future<void> deleteSupplier(int id) async {
    final db = await DatabaseService.db;
    await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }
}
