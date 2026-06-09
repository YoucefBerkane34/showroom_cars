import '../core/database/database_service.dart';
import '../models/client.dart';

class ClientService {
  static Future<List<Client>> getClients({String? search}) async {
    final db = await DatabaseService.db;
    String? where;
    List<dynamic>? whereArgs;

    if (search != null && search.isNotEmpty) {
      final s = '%$search%';
      where = 'full_name LIKE ? OR phone LIKE ? OR wilaya LIKE ? OR company LIKE ?';
      whereArgs = [s, s, s, s];
    }

    final rows = await db.query('clients',
        where: where, whereArgs: whereArgs, orderBy: 'id DESC');
    return rows.map(Client.fromMap).toList();
  }

  static Future<Client?> getClient(int id) async {
    final db = await DatabaseService.db;
    final rows = await db.query('clients', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Client.fromMap(rows.first);
  }

  static Future<int> addClient(Client c) async {
    final db = await DatabaseService.db;
    return db.insert('clients', c.toMap()..remove('id'));
  }

  static Future<void> updateClient(Client c) async {
    final db = await DatabaseService.db;
    await db.update('clients', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  static Future<void> deleteClient(int id) async {
    final db = await DatabaseService.db;
    await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> getTotalCount() async {
    final db = await DatabaseService.db;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM clients');
    return (result.first['cnt'] as int?) ?? 0;
  }
}
