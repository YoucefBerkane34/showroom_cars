class Vehicle {
  int? id;
  String brand;
  String model;
  String color;
  double price;
  String status;

  Vehicle({
    this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.price,
    this.status = "Disponible",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'color': color,
      'price': price,
      'status': status,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      color: map['color'],
      price: map['price'],
      status: map['status'],
    );
  }
}
