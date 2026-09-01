import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';

class SettingsState {
  final String businessName;
  final String ruc;
  final String address;
  final String phone;
  final String machineSeries;
  final String ticketSeries;
  final String boletaSeries;
  final String currency;
  final String themeMode;
  final bool isLoading;

  const SettingsState({
    this.businessName = 'Comercial VentaFácil S.A.C.',
    this.ruc = '20609876543',
    this.address = 'Av. Los Emprendedores 123, Lima - Perú',
    this.phone = '987 654 321',
    this.machineSeries = 'POS-VF2026-01',
    this.ticketSeries = 'T001',
    this.boletaSeries = 'B001',
    this.currency = 'S/.',
    this.themeMode = 'light',
    this.isLoading = false,
  });

  SettingsState copyWith({
    String? businessName,
    String? ruc,
    String? address,
    String? phone,
    String? machineSeries,
    String? ticketSeries,
    String? boletaSeries,
    String? currency,
    String? themeMode,
    bool? isLoading,
  }) {
    return SettingsState(
      businessName: businessName ?? this.businessName,
      ruc: ruc ?? this.ruc,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      machineSeries: machineSeries ?? this.machineSeries,
      ticketSeries: ticketSeries ?? this.ticketSeries,
      boletaSeries: boletaSeries ?? this.boletaSeries,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(const SettingsState()) {
    _loadSettings();
  }

  AppDatabase get _db => _ref.read(databaseProvider);

  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _db.select(_db.appSettings).get();
      String businessName = 'Comercial VentaFácil S.A.C.';
      String ruc = '20609876543';
      String address = 'Av. Los Emprendedores 123, Lima - Perú';
      String phone = '987 654 321';
      String machineSeries = 'POS-VF2026-01';
      String ticketSeries = 'T001';
      String boletaSeries = 'B001';
      String currency = 'S/.';
      String themeMode = 'light';

      for (final s in list) {
        if (s.key == 'business_name') businessName = s.value;
        if (s.key == 'ruc') ruc = s.value;
        if (s.key == 'address') address = s.value;
        if (s.key == 'phone') phone = s.value;
        if (s.key == 'machine_series') machineSeries = s.value;
        if (s.key == 'ticket_series') ticketSeries = s.value;
        if (s.key == 'boleta_series') boletaSeries = s.value;
        if (s.key == 'currency') currency = s.value;
        if (s.key == 'theme_mode') themeMode = s.value;
      }

      state = SettingsState(
        businessName: businessName,
        ruc: ruc,
        address: address,
        phone: phone,
        machineSeries: machineSeries,
        ticketSeries: ticketSeries,
        boletaSeries: boletaSeries,
        currency: currency,
        themeMode: themeMode,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateBusinessField(String key, String value) async {
    state = state.copyWith(isLoading: true);
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSetting(key: key, value: value),
    );
    await _loadSettings();
  }

  Future<void> updateBusinessInfo({
    required String businessName,
    required String ruc,
    required String address,
    required String phone,
    required String machineSeries,
    required String ticketSeries,
    required String boletaSeries,
  }) async {
    state = state.copyWith(isLoading: true);
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.appSettings, [
        AppSetting(key: 'business_name', value: businessName),
        AppSetting(key: 'ruc', value: ruc),
        AppSetting(key: 'address', value: address),
        AppSetting(key: 'phone', value: phone),
        AppSetting(key: 'machine_series', value: machineSeries),
        AppSetting(key: 'ticket_series', value: ticketSeries),
        AppSetting(key: 'boleta_series', value: boletaSeries),
      ]);
    });
    await _loadSettings();
  }

  Future<void> updateCurrency(String currency) async {
    state = state.copyWith(isLoading: true);
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSetting(key: 'currency', value: currency),
    );
    state = state.copyWith(currency: currency, isLoading: false);
  }

  Future<void> updateThemeMode(String mode) async {
    state = state.copyWith(isLoading: true);
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSetting(key: 'theme_mode', value: mode),
    );
    state = state.copyWith(themeMode: mode, isLoading: false);
  }

  Future<String> exportBackup() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'ventafacil.sqlite'));
    
    final backupFolder = await getTemporaryDirectory();
    final backupFile = File(p.join(backupFolder.path, 'ventafacil_backup.sqlite'));
    
    if (await dbFile.exists()) {
      await dbFile.copy(backupFile.path);
      return backupFile.path;
    } else {
      throw Exception('Archivo de base de datos no encontrado.');
    }
  }

  Future<void> importBackup(String backupPath) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'ventafacil.sqlite'));
    
    final backupFile = File(backupPath);
    if (await backupFile.exists()) {
      await _db.close();
      await backupFile.copy(dbFile.path);
      _ref.invalidate(databaseProvider);
      await _loadSettings();
    } else {
      throw Exception('Archivo de respaldo no encontrado.');
    }
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
