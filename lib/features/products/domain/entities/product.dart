class ProductEntity {
  final int id;
  final int? categoryId;
  final String name;
  final String? description;
  final double purchasePrice;
  final double sellingPrice;
  final int stock;
  final int minStock;
  final String? sku;
  final bool isActive;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    this.categoryId,
    required this.name,
    this.description,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.minStock,
    this.sku,
    required this.isActive,
    required this.createdAt,
  });

  double get unitProfit => sellingPrice - purchasePrice;
  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;
}
