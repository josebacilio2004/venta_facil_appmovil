class CustomerEntity {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? notes;
  final DateTime createdAt;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.notes,
    required this.createdAt,
  });
}
