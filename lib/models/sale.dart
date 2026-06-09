class Sale {
  int? id;

  int vehicleId;
  int clientId;

  double price;
  double paidAmount;
  double remainingAmount;

  bool isCredit;
  int months;
  double monthlyPayment;

  String date;

  Sale({
    this.id,
    required this.vehicleId,
    required this.clientId,
    required this.price,
    required this.paidAmount,
    required this.remainingAmount,
    required this.date,
    this.isCredit = false,
    this.months = 0,
    this.monthlyPayment = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'client_id': clientId,
      'price': price,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'is_credit': isCredit ? 1 : 0,
      'months': months,
      'monthly_payment': monthlyPayment,
      'date': date,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      clientId: map['client_id'],
      price: map['price'],
      paidAmount: map['paid_amount'],
      remainingAmount: map['remaining_amount'],
      isCredit: map['is_credit'] == 1,
      months: map['months'],
      monthlyPayment: map['monthly_payment'],
      date: map['date'],
    );
  }
}
