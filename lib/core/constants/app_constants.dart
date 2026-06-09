class AppConstants {
  static const List<String> fuelTypes = [
    'gasoline', 'diesel', 'hybrid', 'electric', 'lpg'
  ];
  static const List<String> transmissions = ['manual', 'automatic'];
  static const List<String> vehicleStatuses = [
    'available', 'reserved', 'sold', 'preparation'
  ];
  static const List<String> paymentMethods = [
    'cash', 'bank_transfer', 'ccp', 'cheque'
  ];
  static const List<String> saleStatuses = [
    'draft', 'confirmed', 'completed', 'cancelled'
  ];
  static const List<String> reservationStatuses = [
    'active', 'expired', 'converted', 'cancelled'
  ];
  static const List<String> expenseTypes = [
    'transportation', 'repairs', 'maintenance', 'cleaning',
    'registration_fees', 'advertising', 'miscellaneous'
  ];
}
