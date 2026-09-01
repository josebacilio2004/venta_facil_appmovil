import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get description => text().nullable()();
  RealColumn get purchasePrice => real()();
  RealColumn get sellingPrice => real()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get minStock => integer().withDefault(const Constant(0))();
  TextColumn get sku => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().withLength(min: 1, max: 20)();
  TextColumn get email => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().nullable().references(Customers, #id, onDelete: KeyAction.setNull)();
  RealColumn get total => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMethod => text()(); // "efectivo", "yape", "plin", "tarjeta", "transferencia", "otro"
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer().references(Products, #id, onDelete: KeyAction.restrict)();
  IntColumn get quantity => integer()();
  RealColumn get unitPurchasePrice => real()();
  RealColumn get unitSellingPrice => real()();
  RealColumn get subtotal => real()();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()(); // "compras", "transporte", "publicidad", "servicios", "alquiler", "otros"
  TextColumn get description => text().withLength(min: 1, max: 250)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get observation => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Categories, Products, Customers, Sales, SaleItems, Expenses, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          
          // Configuración por defecto
          await into(appSettings).insert(AppSettingsCompanion.insert(key: 'business_name', value: 'Mi Negocio'));
          await into(appSettings).insert(AppSettingsCompanion.insert(key: 'currency', value: 'S/.'));
          await into(appSettings).insert(AppSettingsCompanion.insert(key: 'theme_mode', value: 'light'));
          await into(appSettings).insert(AppSettingsCompanion.insert(key: 'yape_name', value: ''));
          await into(appSettings).insert(AppSettingsCompanion.insert(key: 'yape_phone', value: ''));
          await into(appSettings).insert(AppSettingsCompanion.insert(key: 'yape_qr_path', value: ''));
          
          // Categorías predefinidas
          final defaultCategories = ['Abarrotes', 'Bebidas', 'Snacks', 'Limpieza', 'Otros'];
          for (final name in defaultCategories) {
            await into(categories).insert(CategoriesCompanion.insert(name: name));
          }
        },
      );
}
