import '../core/database/database_service.dart';
import '../models/vehicle.dart';

class VehicleService {
  static Future<void> addVehicle(Vehicle v) async {
    final db = await DatabaseService.db;
    await db.insert('vehicles', v.toMap());
  }

  static Future<List<Vehicle>> getVehicles() async {
    final db = await DatabaseService.db;
    final result = await db.query('vehicles');

    return result.map((e) => Vehicle.fromMap(e)).toList();
  }

  static Future<void> deleteVehicle(int id) async {
    final db = await DatabaseService.db;
    await db.delete('vehicles', where: 'id=?', whereArgs: [id]);
  }
}
