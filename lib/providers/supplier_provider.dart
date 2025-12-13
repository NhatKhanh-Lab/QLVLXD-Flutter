import 'package:flutter/foundation.dart';
import '../models/supplier.dart';
import '../services/db_service.dart';

class SupplierProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;

  SupplierProvider() {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _suppliers = DatabaseService.getAllSuppliers();
      _suppliers.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Error loading suppliers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await DatabaseService.addSupplier(supplier);
      await loadSuppliers();
    } catch (e) {
      debugPrint('Error adding supplier: $e');
      rethrow;
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await DatabaseService.updateSupplier(supplier);
      await loadSuppliers();
    } catch (e) {
      debugPrint('Error updating supplier: $e');
      rethrow;
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    try {
      await DatabaseService.deleteSupplier(supplierId);
      await loadSuppliers();
    } catch (e) {
      debugPrint('Error deleting supplier: $e');
      rethrow;
    }
  }

  Supplier? getSupplierById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}

