class Installment {
  int? id;
  int saleId;
  double amount;
  String dueDate;
  String status;

  Installment({
    this.id,
    required this.saleId,
    required this.amount,
    required this.dueDate,
    this.status = "pending",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'amount': amount,
      'due_date': dueDate,
      'status': status,
    };
  }

  factory Installment.fromMap(Map<String, dynamic> map) {
    return Installment(
      id: map['id'],
      saleId: map['sale_id'],
      amount: map['amount'],
      dueDate: map['due_date'],
      status: map['status'],
    );
  }
}
