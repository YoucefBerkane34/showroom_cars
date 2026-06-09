class Reservation {
  int? id;
  int vehicleId;
  int clientId;
  String reservationDate;
  String? expiryDate;
  double deposit;
  String status; // active, expired, converted, cancelled
  String? notes;

  // Joined
  String? vehicleDisplay;
  String? clientDisplay;

  Reservation({
    this.id,
    required this.vehicleId,
    required this.clientId,
    required this.reservationDate,
    this.expiryDate,
    this.deposit = 0,
    this.status = 'active',
    this.notes,
    this.vehicleDisplay,
    this.clientDisplay,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vehicle_id': vehicleId,
        'client_id': clientId,
        'reservation_date': reservationDate,
        'expiry_date': expiryDate,
        'deposit': deposit,
        'status': status,
        'notes': notes,
      };

  factory Reservation.fromMap(Map<String, dynamic> m) => Reservation(
        id: m['id'],
        vehicleId: m['vehicle_id'],
        clientId: m['client_id'],
        reservationDate: m['reservation_date'] ?? '',
        expiryDate: m['expiry_date'],
        deposit: (m['deposit'] ?? 0).toDouble(),
        status: m['status'] ?? 'active',
        notes: m['notes'],
        vehicleDisplay: m['vehicle_display'],
        clientDisplay: m['client_display'],
      );

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.tryParse(expiryDate!)?.isBefore(DateTime.now()) ?? false;
  }
}
