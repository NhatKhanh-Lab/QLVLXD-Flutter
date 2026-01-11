import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/customer.dart';
import '../services/firestore_service.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;
  StreamSubscription<List<Customer>>? _customersSubscription;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  CustomerProvider() {
    _loadCustomers();
  }

  void _loadCustomers() {
    _isLoading = true;
    notifyListeners();

    final stream = FirestoreService.getAllCustomers();

    _customersSubscription = stream.listen(
      (customers) {
        _customers = customers;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading customers from Firestore: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _customersSubscription?.cancel();
    super.dispose();
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await FirestoreService.addCustomer(customer);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error adding customer: $e');
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await FirestoreService.updateCustomer(customer);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error updating customer: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await FirestoreService.deleteCustomer(customerId);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      rethrow;
    }
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateCustomerTotalPurchases(String customerId, double amount) {
    final customer = getCustomerById(customerId);
    if (customer != null) {
      final updatedCustomer = customer.copyWith(
        totalPurchases: customer.totalPurchases + amount,
        updatedAt: DateTime.now(),
      );
      updateCustomer(updatedCustomer);
    }
  }
}

