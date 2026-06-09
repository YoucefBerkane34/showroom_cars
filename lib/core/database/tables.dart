// SQL table creation statements
class AppTables {
  static const String createVehicles = '''
    CREATE TABLE IF NOT EXISTS vehicles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      stock_number TEXT,
      vin TEXT,
      registration TEXT,
      brand TEXT NOT NULL,
      model TEXT NOT NULL,
      version TEXT,
      year INTEGER,
      mileage INTEGER DEFAULT 0,
      fuel_type TEXT,
      transmission TEXT,
      color TEXT,
      engine TEXT,
      purchase_date TEXT,
      purchase_price REAL DEFAULT 0,
      sale_price REAL DEFAULT 0,
      min_sale_price REAL DEFAULT 0,
      supplier TEXT,
      notes TEXT,
      status TEXT DEFAULT 'available'
    )
  ''';

  static const String createClients = '''
    CREATE TABLE IF NOT EXISTS clients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL,
      phone TEXT,
      whatsapp TEXT,
      email TEXT,
      address TEXT,
      wilaya TEXT,
      client_type TEXT DEFAULT 'individual',
      company TEXT,
      notes TEXT
    )
  ''';

  static const String createSales = '''
    CREATE TABLE IF NOT EXISTS sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      vehicle_id INTEGER NOT NULL,
      client_id INTEGER NOT NULL,
      sale_date TEXT NOT NULL,
      total_price REAL NOT NULL,
      paid_amount REAL DEFAULT 0,
      remaining_amount REAL DEFAULT 0,
      payment_method TEXT DEFAULT 'cash',
      status TEXT DEFAULT 'draft',
      notes TEXT,
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
      FOREIGN KEY (client_id) REFERENCES clients(id)
    )
  ''';

  static const String createReservations = '''
    CREATE TABLE IF NOT EXISTS reservations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      vehicle_id INTEGER NOT NULL,
      client_id INTEGER NOT NULL,
      reservation_date TEXT NOT NULL,
      expiry_date TEXT,
      deposit REAL DEFAULT 0,
      status TEXT DEFAULT 'active',
      notes TEXT,
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
      FOREIGN KEY (client_id) REFERENCES clients(id)
    )
  ''';

  static const String createExpenses = '''
    CREATE TABLE IF NOT EXISTS expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      vehicle_id INTEGER,
      expense_type TEXT NOT NULL,
      amount REAL NOT NULL,
      description TEXT,
      expense_date TEXT NOT NULL,
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
    )
  ''';

  static const String createSuppliers = '''
    CREATE TABLE IF NOT EXISTS suppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      address TEXT,
      wilaya TEXT,
      notes TEXT
    )
  ''';
}
