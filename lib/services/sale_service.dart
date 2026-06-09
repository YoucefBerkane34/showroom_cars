import '../core/database/database_service.dart';
import '../models/sale.dart';
import 'installment_service.dart';
import '../models/installment.dart';

class SaleService {
  static Future<int> addSale(Sale s) async {
    final db = await DatabaseService.db;

    int saleId = await db.insert('sales', s.toMap());

    // تحديث حالة السيارة إلى Vendue
    await db.update(
      'vehicles',
      {'status': 'Vendue'},
      where: 'id=?',
      whereArgs: [s.vehicleId],
    );

    // إنشاء الأقساط إذا كان تقسيط
    if (s.isCredit && s.months > 0) {
      await generateInstallments(
        saleId,
        s.price,
        s.months,
      );
    }

    return saleId;
  }

  static Future<List<Sale>> getSales() async {
    final db = await DatabaseService.db;
    final result = await db.query('sales');

    return result.map((e) => Sale.fromMap(e)).toList();
  }

  static Future<void> generateInstallments(
    int saleId,
    double total,
    int months,
  ) async {
    if (months <= 0) return;

    double monthly = total / months;

    DateTime start = DateTime.now();

    for (int i = 1; i <= months; i++) {
      DateTime due = DateTime(
        start.year,
        start.month + i,
        start.day,
      );

      await InstallmentService.addInstallment(
        Installment(
          saleId: saleId,
          amount: monthly,
          dueDate: due.toIso8601String().split("T")[0], // YYYY-MM-DD
          status: "pending",
        ),
      );
    }
  }
}
