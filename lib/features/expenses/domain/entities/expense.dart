class ExpenseEntity {
  final int id;
  final String category; // "compras", "transporte", "publicidad", "servicios", "alquiler", "otros"
  final String description;
  final double amount;
  final DateTime date;
  final String? observation;
  final DateTime createdAt;

  const ExpenseEntity({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.observation,
    required this.createdAt,
  });
}
