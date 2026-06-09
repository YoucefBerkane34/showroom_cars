import '../core/database/database_service.dart';
import '../models/client.dart';

class ClientService {
  static Future<void> addClient(Client c) async {
    final db = await DatabaseService.db;
    await db.insert('clients', c.toMap());
  }

  static Future<List<Client>> getClients() async {
    final db = await DatabaseService.db;
    final result = await db.query('clients');

    return result.map((e) => Client.fromMap(e)).toList();
  }

  static Future<void> deleteClient(int id) async {
    final db = await DatabaseService.db;
    await db.delete('clients', where: 'id=?', whereArgs: [id]);
  }
}
