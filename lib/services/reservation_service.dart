import '../core/database/database_service.dart';
import '../models/reservation.dart';

class ReservationService {
  static Future<List<Reservation>> getReservations({String? status}) async {
    final db = await DatabaseService.db;
    final rows = await db.rawQuery('''
      SELECT r.*,
        (v.brand || ' ' || v.model) as vehicle_display,
        c.full_name as client_display
      FROM reservations r
      LEFT JOIN vehicles v ON r.vehicle_id = v.id
      LEFT JOIN clients c ON r.client_id = c.id
      ORDER BY r.id DESC
    ''');
    var list = rows.map(Reservation.fromMap).toList();
    if (status != null && status != 'all') {
      list = list.where((r) => r.status == status).toList();
    }
    return list;
  }

  static Future<int> addReservation(Reservation r) async {
    final db = await DatabaseService.db;
    return db.insert('reservations', r.toMap()..remove('id'));
  }

  static Future<void> updateReservation(Reservation r) async {
    final db = await DatabaseService.db;
    await db.update('reservations', r.toMap(),
        where: 'id = ?', whereArgs: [r.id]);
  }

  static Future<void> updateStatus(int id, String status) async {
    final db = await DatabaseService.db;
    await db.update('reservations', {'status': status},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteReservation(int id) async {
    final db = await DatabaseService.db;
    await db.delete('reservations', where: 'id = ?', whereArgs: [id]);
  }
}
