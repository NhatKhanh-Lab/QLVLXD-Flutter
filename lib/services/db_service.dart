import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/supplier.dart';
import '../models/customer.dart';
import '../models/purchase_order.dart';

class DatabaseService {
  static const String productBoxName = 'products';
  static const String invoiceBoxName = 'invoices';
  static const String supplierBoxName = 'suppliers';
  static const String customerBoxName = 'customers';
  static const String purchaseOrderBoxName = 'purchase_orders';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(InvoiceItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(InvoiceAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SupplierAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CustomerAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(PurchaseOrderAdapter());
    }

    // Open boxes
    await Hive.openBox<Product>(productBoxName);
    await Hive.openBox<Invoice>(invoiceBoxName);
    await Hive.openBox<Supplier>(supplierBoxName);
    await Hive.openBox<Customer>(customerBoxName);
    await Hive.openBox<PurchaseOrder>(purchaseOrderBoxName);
  }

  // Product operations
  static Box<Product> get productBox => Hive.box<Product>(productBoxName);
  static Box<Invoice> get invoiceBox => Hive.box<Invoice>(invoiceBoxName);

  // Product CRUD
  static Future<void> addProduct(Product product) async {
    await productBox.put(product.id, product);
  }

  static Future<void> updateProduct(Product product) async {
    await productBox.put(product.id, product);
  }

  static Future<void> deleteProduct(String productId) async {
    await productBox.delete(productId);
  }

  static Product? getProduct(String productId) {
    return productBox.get(productId);
  }

  static List<Product> getAllProducts() {
    return productBox.values.toList();
  }

  static List<Product> getProductsByCategory(String category) {
    return productBox.values
        .where((product) => product.category == category)
        .toList();
  }

  static List<Product> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return productBox.values
        .where((product) =>
            product.name.toLowerCase().contains(lowerQuery) ||
            product.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  static List<Product> getLowStockProducts() {
    return productBox.values
        .where((product) => product.isLowStock)
        .toList();
  }

  // Invoice CRUD
  static Future<void> addInvoice(Invoice invoice) async {
    await invoiceBox.put(invoice.id, invoice);
  }

  static Future<void> updateInvoice(Invoice invoice) async {
    await invoiceBox.put(invoice.id, invoice);
  }

  static Future<void> deleteInvoice(String invoiceId) async {
    await invoiceBox.delete(invoiceId);
  }

  static Invoice? getInvoice(String invoiceId) {
    return invoiceBox.get(invoiceId);
  }

  static List<Invoice> getAllInvoices() {
    return invoiceBox.values.toList();
  }

  static List<Invoice> getInvoicesByDateRange(DateTime start, DateTime end) {
    return invoiceBox.values
        .where((invoice) =>
            invoice.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
            invoice.createdAt.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // Statistics
  static double getTotalInventoryValue() {
    return productBox.values
        .fold(0.0, (sum, product) => sum + product.totalValue);
  }

  static double getTodayRevenue() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return invoiceBox.values
        .where((invoice) =>
            invoice.createdAt.isAfter(startOfDay) &&
            invoice.createdAt.isBefore(endOfDay))
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  static Map<String, int> getProductSalesCount() {
    final Map<String, int> salesCount = {};
    for (final invoice in invoiceBox.values) {
      for (final item in invoice.items) {
        salesCount[item.productId] =
            (salesCount[item.productId] ?? 0) + item.quantity;
      }
    }
    return salesCount;
  }

  // Backup & Restore
  static Map<String, dynamic> exportData() {
    return {
      'products': productBox.values.map((p) => p.toMap()).toList(),
      'invoices': invoiceBox.values.map((i) => i.toMap()).toList(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await productBox.clear();
    await invoiceBox.clear();

    // Import products
    if (data['products'] != null) {
      for (final productMap in data['products'] as List) {
        final product = Product.fromMap(productMap as Map<String, dynamic>);
        await productBox.put(product.id, product);
      }
    }

    // Import invoices
    if (data['invoices'] != null) {
      for (final invoiceMap in data['invoices'] as List) {
        final invoice = Invoice.fromMap(invoiceMap as Map<String, dynamic>);
        await invoiceBox.put(invoice.id, invoice);
      }
    }
  }

  static Future<void> clearAllData() async {
    await productBox.clear();
    await invoiceBox.clear();
    await supplierBox.clear();
    await customerBox.clear();
    await purchaseOrderBox.clear();
  }

  // Supplier operations
  static Box<Supplier> get supplierBox => Hive.box<Supplier>(supplierBoxName);

  static Future<void> addSupplier(Supplier supplier) async {
    await supplierBox.put(supplier.id, supplier);
  }

  static Future<void> updateSupplier(Supplier supplier) async {
    await supplierBox.put(supplier.id, supplier);
  }

  static Future<void> deleteSupplier(String supplierId) async {
    await supplierBox.delete(supplierId);
  }

  static Supplier? getSupplier(String supplierId) {
    return supplierBox.get(supplierId);
  }

  static List<Supplier> getAllSuppliers() {
    return supplierBox.values.toList();
  }

  // Customer operations
  static Box<Customer> get customerBox => Hive.box<Customer>(customerBoxName);

  static Future<void> addCustomer(Customer customer) async {
    await customerBox.put(customer.id, customer);
  }

  static Future<void> updateCustomer(Customer customer) async {
    await customerBox.put(customer.id, customer);
  }

  static Future<void> deleteCustomer(String customerId) async {
    await customerBox.delete(customerId);
  }

  static Customer? getCustomer(String customerId) {
    return customerBox.get(customerId);
  }

  static List<Customer> getAllCustomers() {
    return customerBox.values.toList();
  }

  // Purchase Order operations
  static Box<PurchaseOrder> get purchaseOrderBox => Hive.box<PurchaseOrder>(purchaseOrderBoxName);

  static Future<void> addPurchaseOrder(PurchaseOrder order) async {
    await purchaseOrderBox.put(order.id, order);
  }

  static Future<void> updatePurchaseOrder(PurchaseOrder order) async {
    await purchaseOrderBox.put(order.id, order);
  }

  static Future<void> deletePurchaseOrder(String orderId) async {
    await purchaseOrderBox.delete(orderId);
  }

  static PurchaseOrder? getPurchaseOrder(String orderId) {
    return purchaseOrderBox.get(orderId);
  }

  static List<PurchaseOrder> getAllPurchaseOrders() {
    return purchaseOrderBox.values.toList();
  }

  static List<PurchaseOrder> getPurchaseOrdersByStatus(String status) {
    return purchaseOrderBox.values
        .where((order) => order.status == status)
        .toList();
  }
}

