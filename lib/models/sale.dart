class Sale {
  int? id;
  int vehicleId;
  int clientId;
  String saleDate;
  double totalPrice;
  double paidAmount;
  double remainingAmount;
  String paymentMethod; // cash, bank_transfer, ccp, cheque
  String status; // draft, confirmed, completed, cancelled
  String? notes;

  // Joined data (not stored in DB)
  String? vehicleDisplay;
  String? clientDisplay;

  Sale({
    this.id,
    required this.vehicleId,
    required this.clientId,
    required this.saleDate,
    required this.totalPrice,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.paymentMethod = 'cash',
    this.status = 'draft',
    this.notes,
    this.vehicleDisplay,
    this.clientDisplay,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vehicle_id': vehicleId,
        'client_id': clientId,
        'sale_date': saleDate,
        'total_price': totalPrice,
        'paid_amount': paidAmount,
        'remaining_amount': remainingAmount,
        'payment_method': paymentMethod,
        'status': status,
        'notes': notes,
      };

  factory Sale.fromMap(Map<String, dynamic> m) => Sale(
        id: m['id'],
        vehicleId: m['vehicle_id'],
        clientId: m['client_id'],
        saleDate: m['sale_date'] ?? '',
        totalPrice: (m['total_price'] ?? 0).toDouble(),
        paidAmount: (m['paid_amount'] ?? 0).toDouble(),
        remainingAmount: (m['remaining_amount'] ?? 0).toDouble(),
        paymentMethod: m['payment_method'] ?? 'cash',
        status: m['status'] ?? 'draft',
        notes: m['notes'],
        vehicleDisplay: m['vehicle_display'],
        clientDisplay: m['client_display'],
      );
}
