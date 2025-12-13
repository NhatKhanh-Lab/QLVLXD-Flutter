import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/db_service.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  CustomerProvider() {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = DatabaseService.getAllCustomers();
      _customers.sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await DatabaseService.addCustomer(customer);
      await loadCustomers();
    } catch (e) {
      debugPrint('Error adding customer: $e');
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await DatabaseService.updateCustomer(customer);
      await loadCustomers();
    } catch (e) {
      debugPrint('Error updating customer: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await DatabaseService.deleteCustomer(customerId);
      await loadCustomers();
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

