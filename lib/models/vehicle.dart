class Vehicle {
  int? id;
  String? stockNumber;
  String? vin;
  String? registration;
  String brand;
  String model;
  String? version;
  int? year;
  int mileage;
  String? fuelType;
  String? transmission;
  String? color;
  String? engine;
  String? purchaseDate;
  double purchasePrice;
  double salePrice;
  double minSalePrice;
  String? supplier;
  String? notes;
  String status;

  Vehicle({
    this.id,
    this.stockNumber,
    this.vin,
    this.registration,
    required this.brand,
    required this.model,
    this.version,
    this.year,
    this.mileage = 0,
    this.fuelType,
    this.transmission,
    this.color,
    this.engine,
    this.purchaseDate,
    this.purchasePrice = 0,
    this.salePrice = 0,
    this.minSalePrice = 0,
    this.supplier,
    this.notes,
    this.status = 'available',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'stock_number': stockNumber,
        'vin': vin,
        'registration': registration,
        'brand': brand,
        'model': model,
        'version': version,
        'year': year,
        'mileage': mileage,
        'fuel_type': fuelType,
        'transmission': transmission,
        'color': color,
        'engine': engine,
        'purchase_date': purchaseDate,
        'purchase_price': purchasePrice,
        'sale_price': salePrice,
        'min_sale_price': minSalePrice,
        'supplier': supplier,
        'notes': notes,
        'status': status,
      };

  factory Vehicle.fromMap(Map<String, dynamic> m) => Vehicle(
        id: m['id'],
        stockNumber: m['stock_number'],
        vin: m['vin'],
        registration: m['registration'],
        brand: m['brand'] ?? '',
        model: m['model'] ?? '',
        version: m['version'],
        year: m['year'],
        mileage: m['mileage'] ?? 0,
        fuelType: m['fuel_type'],
        transmission: m['transmission'],
        color: m['color'],
        engine: m['engine'],
        purchaseDate: m['purchase_date'],
        purchasePrice: (m['purchase_price'] ?? 0).toDouble(),
        salePrice: (m['sale_price'] ?? 0).toDouble(),
        minSalePrice: (m['min_sale_price'] ?? 0).toDouble(),
        supplier: m['supplier'],
        notes: m['notes'],
        status: m['status'] ?? 'available',
      );

  double get profit => salePrice - purchasePrice;

  String get displayName => '$brand $model${year != null ? " ($year)" : ""}';
}
