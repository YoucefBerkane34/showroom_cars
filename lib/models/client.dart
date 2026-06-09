class Client {
  int? id;
  String fullName;
  String? phone;
  String? whatsapp;
  String? email;
  String? address;
  String? wilaya;
  String clientType; // 'individual' or 'corporate'
  String? company;
  String? notes;

  Client({
    this.id,
    required this.fullName,
    this.phone,
    this.whatsapp,
    this.email,
    this.address,
    this.wilaya,
    this.clientType = 'individual',
    this.company,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'phone': phone,
        'whatsapp': whatsapp,
        'email': email,
        'address': address,
        'wilaya': wilaya,
        'client_type': clientType,
        'company': company,
        'notes': notes,
      };

  factory Client.fromMap(Map<String, dynamic> m) => Client(
        id: m['id'],
        fullName: m['full_name'] ?? '',
        phone: m['phone'],
        whatsapp: m['whatsapp'],
        email: m['email'],
        address: m['address'],
        wilaya: m['wilaya'],
        clientType: m['client_type'] ?? 'individual',
        company: m['company'],
        notes: m['notes'],
      );
}
