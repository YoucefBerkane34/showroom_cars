class Expense {
  int? id;
  int? vehicleId;
  String expenseType;
  double amount;
  String? description;
  String expenseDate;

  // Joined
  String? vehicleDisplay;

  Expense({
    this.id,
    this.vehicleId,
    required this.expenseType,
    required this.amount,
    this.description,
    required this.expenseDate,
    this.vehicleDisplay,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vehicle_id': vehicleId,
        'expense_type': expenseType,
        'amount': amount,
        'description': description,
        'expense_date': expenseDate,
      };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'],
        vehicleId: m['vehicle_id'],
        expenseType: m['expense_type'] ?? '',
        amount: (m['amount'] ?? 0).toDouble(),
        description: m['description'],
        expenseDate: m['expense_date'] ?? '',
        vehicleDisplay: m['vehicle_display'],
      );
}
