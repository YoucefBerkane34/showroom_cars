import '../core/database/database_service.dart';
import '../models/installment.dart';

class InstallmentService {
  static Future<void> addInstallment(Installment i) async {
    final db = await DatabaseService.db;
    await db.insert('installments', i.toMap());
  }

  static Future<List<Installment>> getBySale(int saleId) async {
    final db = await DatabaseService.db;

    final result = await db.query(
      'installments',
      where: 'sale_id=?',
      whereArgs: [saleId],
    );

    return result.map((e) => Installment.fromMap(e)).toList();
  }

  static Future<void> markPaid(int id) async {
    final db = await DatabaseService.db;

    await db.update(
      'installments',
      {'status': 'paid'},
      where: 'id=?',
      whereArgs: [id],
    );
  }
}
