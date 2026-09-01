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

  ProductEntity copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? description,
    double? purchasePrice,
    double? sellingPrice,
    int? stock,
    int? minStock,
    String? sku,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      sku: sku ?? this.sku,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get unitProfit => sellingPrice - purchasePrice;
  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;
}
