import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/supplier.dart';
import '../services/firestore_service.dart';

class SupplierProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  StreamSubscription<List<Supplier>>? _suppliersSubscription;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;

  SupplierProvider() {
    _loadSuppliers();
  }

  void _loadSuppliers() {
    _isLoading = true;
    notifyListeners();

    final stream = FirestoreService.getAllSuppliers();

    _suppliersSubscription = stream.listen(
      (suppliers) {
        _suppliers = suppliers;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading suppliers from Firestore: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _suppliersSubscription?.cancel();
    super.dispose();
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await FirestoreService.addSupplier(supplier);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error adding supplier: $e');
      rethrow;
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await FirestoreService.updateSupplier(supplier);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error updating supplier: $e');
      rethrow;
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    try {
      await FirestoreService.deleteSupplier(supplierId);
      // No need to reload - stream will automatically update
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

