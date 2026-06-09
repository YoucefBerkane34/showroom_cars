class Client {
  int? id;
  String name;
  String phone;
  String address;

  Client({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
    );
  }
}
