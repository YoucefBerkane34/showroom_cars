import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'tables.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    sqfliteFfiInit();
    final factory = databaseFactoryFfi;
    final dbPath = await factory.getDatabasesPath();
    final path = join(dbPath, 'showroom_v1.db');

    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(AppTables.createVehicles);
          await db.execute(AppTables.createClients);
          await db.execute(AppTables.createSales);
          await db.execute(AppTables.createReservations);
          await db.execute(AppTables.createExpenses);
          await db.execute(AppTables.createSuppliers);
        },
      ),
    );
  }
}
