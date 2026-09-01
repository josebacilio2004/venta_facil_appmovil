class SaleItemEntity {
  final int id;
  final int saleId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPurchasePrice;
  final double unitSellingPrice;
  final double subtotal;

  const SaleItemEntity({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPurchasePrice,
    required this.unitSellingPrice,
    required this.subtotal,
  });

  double get unitProfit => unitSellingPrice - unitPurchasePrice;
  double get totalProfit => quantity * unitProfit;
}
