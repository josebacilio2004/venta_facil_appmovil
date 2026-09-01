import 'package:flutter_test/flutter_test.dart';
import 'package:ventafacil/features/products/domain/entities/product.dart';
import 'package:ventafacil/features/sales/domain/entities/cart_item.dart';
import 'package:ventafacil/features/sales/presentation/providers/sales_providers.dart';

void main() {
  group('ProductEntity Tests', () {
    test('Debería calcular la ganancia unitaria correctamente', () {
      final product = ProductEntity(
        id: 1,
        name: 'Gaseosa',
        purchasePrice: 2.50,
        sellingPrice: 3.50,
        stock: 10,
        minStock: 2,
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(product.unitProfit, 1.00);
    });

    test('Debería alertar stock bajo correctamente', () {
      final normalProduct = ProductEntity(
        id: 1,
        name: 'Gaseosa',
        purchasePrice: 2.50,
        sellingPrice: 3.50,
        stock: 10,
        minStock: 2,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final lowStockProduct = ProductEntity(
        id: 2,
        name: 'Galletas',
        purchasePrice: 1.00,
        sellingPrice: 1.50,
        stock: 2,
        minStock: 3,
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(normalProduct.isLowStock, false);
      expect(lowStockProduct.isLowStock, true);
    });
  });

  group('CartState Tests', () {
    final product1 = ProductEntity(
      id: 1,
      name: 'Artículo A',
      purchasePrice: 1.00,
      sellingPrice: 2.00,
      stock: 10,
      minStock: 1,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final product2 = ProductEntity(
      id: 2,
      name: 'Artículo B',
      purchasePrice: 3.00,
      sellingPrice: 5.00,
      stock: 5,
      minStock: 1,
      isActive: true,
      createdAt: DateTime.now(),
    );

    test('Debería calcular subtotal y total sin descuento correctamente', () {
      final items = [
        CartItemEntity(product: product1, quantity: 3), // Subtotal: 6.0
        CartItemEntity(product: product2, quantity: 1), // Subtotal: 5.0
      ];

      final cartState = CartState(items: items);

      expect(cartState.subtotal, 11.00);
      expect(cartState.total, 11.00);
    });

    test('Debería aplicar descuento al total correctamente', () {
      final items = [
        CartItemEntity(product: product1, quantity: 3), // Subtotal: 6.0
        CartItemEntity(product: product2, quantity: 1), // Subtotal: 5.0
      ];

      final cartState = CartState(items: items, discount: 2.50);

      expect(cartState.subtotal, 11.00);
      expect(cartState.total, 8.50);
    });

    test('El total no debería ser menor a cero si el descuento supera el subtotal', () {
      final items = [
        CartItemEntity(product: product1, quantity: 1), // Subtotal: 2.0
      ];

      final cartState = CartState(items: items, discount: 5.00);

      expect(cartState.total, 0.0);
    });
  });
}
