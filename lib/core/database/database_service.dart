import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;

    String databasesPath = await databaseFactory.getDatabasesPath();
    // تم تغيير اسم الملف إلى showroom_v3 لضمان بناء الجداول الجديدة كاملة
    String path = join(databasesPath, 'showroom_v3.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // 1. إنشاء جدول السيارات
          await db.execute('''
            CREATE TABLE vehicles (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              brand TEXT,
              model TEXT,
              color TEXT,
              price REAL,
              status TEXT
            )
          ''');

          // 2. إنشاء جدول العملاء
          await db.execute('''
            CREATE TABLE clients (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              phone TEXT,
              address TEXT
            )
          ''');

          // 3. إنشاء جدول المبيعات (مع تحديث حقول الأقساط والائتمان)
          await db.execute('''
            CREATE TABLE sales (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              vehicle_id INTEGER,
              client_id INTEGER,
              price REAL,
              paid_amount REAL,
              remaining_amount REAL,
              date TEXT,
              is_credit INTEGER, -- 1 للتقسيط و 0 للكاش
              months INTEGER,
              monthly_payment REAL,
              FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE,
              FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE CASCADE
            )
          ''');

          // 4. إنشاء جدول الأقساط الجديد وربطه بجدول المبيعات
          await db.execute('''
            CREATE TABLE installments (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              sale_id INTEGER,
              amount REAL,
              due_date TEXT,
              status TEXT, -- مثل: 'مدفوع' أو 'مستحق' أو 'متأخر'
              FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
            )
          ''');
        },
      ),
    );
  }
}
