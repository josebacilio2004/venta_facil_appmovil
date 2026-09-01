class SaleEntity {
  final int id;
  final int? customerId;
  final String? customerName;
  final double total;
  final double discount;
  final String paymentMethod;
  final DateTime date;
  final DateTime createdAt;

  const SaleEntity({
    required this.id,
    this.customerId,
    this.customerName,
    required this.total,
    required this.discount,
    required this.paymentMethod,
    required this.date,
    required this.createdAt,
  });

  double get subtotal => total + discount;
}
