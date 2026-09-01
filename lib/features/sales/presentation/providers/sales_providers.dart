import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/sales_local_datasource.dart';
import '../../data/repository_implementations/sales_repository_impl.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/use_cases/sales_use_cases.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/entities/cart_item.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_providers.dart';

// Datasource
final salesLocalDataSourceProvider = Provider<SalesLocalDataSource>((ref) {
  return SalesLocalDataSourceImpl(ref.watch(databaseProvider));
});

// Repository
final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepositoryImpl(
    ref.watch(salesLocalDataSourceProvider),
    ref.watch(databaseProvider),
  );
});

// Use Cases
final registerSaleUseCaseProvider = Provider<RegisterSaleUseCase>((ref) {
  return RegisterSaleUseCase(ref.watch(salesRepositoryProvider));
});

final getSalesUseCaseProvider = Provider<GetSalesUseCase>((ref) {
  return GetSalesUseCase(ref.watch(salesRepositoryProvider));
});

final getSaleItemsUseCaseProvider = Provider<GetSaleItemsUseCase>((ref) {
  return GetSaleItemsUseCase(ref.watch(salesRepositoryProvider));
});

// Sales List Notifier
class SalesListNotifier extends AsyncNotifier<List<SaleEntity>> {
  @override
  Future<List<SaleEntity>> build() async {
    return ref.watch(getSalesUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(getSalesUseCaseProvider).call();
    });
  }
}

final salesListProvider = AsyncNotifierProvider<SalesListNotifier, List<SaleEntity>>(() {
  return SalesListNotifier();
});

// Cart State
class CartState {
  final List<CartItemEntity> items;
  final double discount;

  const CartState({this.items = const [], this.discount = 0.0});

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get total => subtotal - discount > 0 ? subtotal - discount : 0.0;
  
  CartState copyWith({List<CartItemEntity>? items, double? discount}) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
    );
  }
}

// Cart Notifier / Controller
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(ProductEntity product) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      final existingItem = state.items[existingIndex];
      if (existingItem.quantity >= product.stock) return;
      
      final updatedItems = List<CartItemEntity>.from(state.items);
      updatedItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
      state = state.copyWith(items: updatedItems);
    } else {
      if (product.stock <= 0) return;
      state = state.copyWith(items: [...state.items, CartItemEntity(product: product, quantity: 1)]);
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final item = state.items[index];
      final finalQty = quantity > item.product.stock ? item.product.stock : quantity;
      
      final updatedItems = List<CartItemEntity>.from(state.items);
      updatedItems[index] = item.copyWith(quantity: finalQty);
      state = state.copyWith(items: updatedItems);
    }
  }

  void removeItem(int productId) {
    state = state.copyWith(items: state.items.where((i) => i.product.id != productId).toList());
    if (state.items.isEmpty) {
      state = state.copyWith(discount: 0.0);
    }
  }

  void applyDiscount(double discount) {
    if (discount < 0) return;
    state = state.copyWith(discount: discount);
  }

  void clearCart() {
    state = const CartState();
  }

  Future<int> checkout({
    required int? customerId,
    required String paymentMethod,
    required WidgetRef ref,
  }) async {
    if (state.items.isEmpty) return 0;

    final sale = SaleEntity(
      id: 0,
      customerId: customerId,
      total: state.total,
      discount: state.discount,
      paymentMethod: paymentMethod,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final saleItems = state.items.map((c) => SaleItemEntity(
      id: 0,
      saleId: 0,
      productId: c.product.id,
      productName: c.product.name,
      quantity: c.quantity,
      unitPurchasePrice: c.product.purchasePrice,
      unitSellingPrice: c.product.sellingPrice,
      subtotal: c.subtotal,
    )).toList();

    final saleId = await ref.read(registerSaleUseCaseProvider).call(sale, saleItems);
    
    clearCart();

    ref.invalidate(productsListProvider);
    ref.invalidate(salesListProvider);

    return saleId;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
