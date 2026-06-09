class Supplier {
  int? id;
  String name;
  String? phone;
  String? email;
  String? address;
  String? wilaya;
  String? notes;

  Supplier({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.wilaya,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'wilaya': wilaya,
        'notes': notes,
      };

  factory Supplier.fromMap(Map<String, dynamic> m) => Supplier(
        id: m['id'],
        name: m['name'] ?? '',
        phone: m['phone'],
        email: m['email'],
        address: m['address'],
        wilaya: m['wilaya'],
        notes: m['notes'],
      );
}
