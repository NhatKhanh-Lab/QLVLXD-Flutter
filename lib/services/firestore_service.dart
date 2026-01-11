import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/supplier.dart';
import '../models/customer.dart';
import '../models/purchase_order.dart';

/// Main Firestore service - replaces Hive completely
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String productsCollection = 'products';
  static const String invoicesCollection = 'invoices';
  static const String suppliersCollection = 'suppliers';
  static const String customersCollection = 'customers';
  static const String purchaseOrdersCollection = 'purchase_orders';
  static const String usersCollection = 'users';

  // ==================== PRODUCTS ====================
  static CollectionReference<Product> get productsRef =>
      _firestore.collection(productsCollection).withConverter<Product>(
            fromFirestore: (snapshot, _) => Product.fromMap(snapshot.data()!),
            toFirestore: (product, _) => product.toMap(),
          );

  static Future<void> addProduct(Product product) async {
    try {
      await productsRef.doc(product.id).set(product);
    } catch (e) {
      debugPrint('Add product error: $e');
      rethrow;
    }
  }

  static Future<void> updateProduct(Product product) async {
    try {
      await productsRef.doc(product.id).update(product.toMap());
    } catch (e) {
      debugPrint('Update product error: $e');
      rethrow;
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      await productsRef.doc(productId).delete();
    } catch (e) {
      debugPrint('Delete product error: $e');
      rethrow;
    }
  }

  static Future<Product?> getProduct(String productId) async {
    try {
      final doc = await productsRef.doc(productId).get();
      return doc.data();
    } catch (e) {
      debugPrint('Get product error: $e');
      return null;
    }
  }

  static Stream<List<Product>> getAllProducts() {
    return productsRef.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  static Stream<List<Product>> getProductsByCategory(String category) {
    return productsRef
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Stream<List<Product>> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return productsRef.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .where((product) =>
                  product.name.toLowerCase().contains(lowerQuery) ||
                  product.category.toLowerCase().contains(lowerQuery))
              .toList(),
        );
  }

  static Stream<List<Product>> getLowStockProducts(int minStock) {
    return productsRef
        .where('quantity', isLessThan: minStock)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ==================== INVOICES ====================
  static CollectionReference<Invoice> get invoicesRef =>
      _firestore.collection(invoicesCollection).withConverter<Invoice>(
            fromFirestore: (snapshot, _) {
              final rawData = snapshot.data() as Map<String, dynamic>?;
              if (rawData == null) {
                throw Exception('Invoice data is null');
              }
              
              // Create a mutable copy and convert Firestore Timestamp to DateTime
              final data = Map<String, dynamic>.from(rawData);
              if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
                data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
              }
              return Invoice.fromMap(data);
            },
            toFirestore: (invoice, _) {
              final data = invoice.toMap();
              // Convert DateTime to Firestore Timestamp
              if (data['createdAt'] is DateTime) {
                data['createdAt'] = Timestamp.fromDate(data['createdAt'] as DateTime);
              }
              return data;
            },
          );

  static Future<void> addInvoice(Invoice invoice) async {
    try {
      await invoicesRef.doc(invoice.id).set(invoice);
    } catch (e) {
      debugPrint('Add invoice error: $e');
      rethrow;
    }
  }

  static Future<void> updateInvoice(Invoice invoice) async {
    try {
      await invoicesRef.doc(invoice.id).update(invoice.toMap());
    } catch (e) {
      debugPrint('Update invoice error: $e');
      rethrow;
    }
  }

  static Future<void> deleteInvoice(String invoiceId) async {
    try {
      await invoicesRef.doc(invoiceId).delete();
    } catch (e) {
      debugPrint('Delete invoice error: $e');
      rethrow;
    }
  }

  static Future<Invoice?> getInvoice(String invoiceId) async {
    try {
      final doc = await invoicesRef.doc(invoiceId).get();
      return doc.data();
    } catch (e) {
      debugPrint('Get invoice error: $e');
      return null;
    }
  }

  static Stream<List<Invoice>> getAllInvoices() {
    return invoicesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Stream<List<Invoice>> getInvoicesByUser(String userId) {
    // Note: Filter by createdBy and order by createdAt
    // If this requires composite index, Firestore will show error with link to create index
    return invoicesRef
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Stream<List<Invoice>> getInvoicesByDateRange(
    DateTime start,
    DateTime end,
  ) {
    // Convert DateTime to Timestamp for Firestore query
    final startTimestamp = Timestamp.fromDate(start);
    final endTimestamp = Timestamp.fromDate(end);
    
    // Use isLessThan (not isLessThanOrEqualTo) to avoid including invoices from the next day
    // when end is set to startOfDay + 1 day
    return invoicesRef
        .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
        .where('createdAt', isLessThan: endTimestamp)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ==================== SUPPLIERS ====================
  static CollectionReference<Supplier> get suppliersRef =>
      _firestore.collection(suppliersCollection).withConverter<Supplier>(
            fromFirestore: (snapshot, _) => Supplier.fromMap(snapshot.data()!),
            toFirestore: (supplier, _) => supplier.toMap(),
          );

  static Future<void> addSupplier(Supplier supplier) async {
    try {
      await suppliersRef.doc(supplier.id).set(supplier);
    } catch (e) {
      debugPrint('Add supplier error: $e');
      rethrow;
    }
  }

  static Future<void> updateSupplier(Supplier supplier) async {
    try {
      await suppliersRef.doc(supplier.id).update(supplier.toMap());
    } catch (e) {
      debugPrint('Update supplier error: $e');
      rethrow;
    }
  }

  static Future<void> deleteSupplier(String supplierId) async {
    try {
      await suppliersRef.doc(supplierId).delete();
    } catch (e) {
      debugPrint('Delete supplier error: $e');
      rethrow;
    }
  }

  static Stream<List<Supplier>> getAllSuppliers() {
    return suppliersRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ==================== CUSTOMERS ====================
  static CollectionReference<Customer> get customersRef =>
      _firestore.collection(customersCollection).withConverter<Customer>(
            fromFirestore: (snapshot, _) => Customer.fromMap(snapshot.data()!),
            toFirestore: (customer, _) => customer.toMap(),
          );

  static Future<void> addCustomer(Customer customer) async {
    try {
      await customersRef.doc(customer.id).set(customer);
    } catch (e) {
      debugPrint('Add customer error: $e');
      rethrow;
    }
  }

  static Future<void> updateCustomer(Customer customer) async {
    try {
      await customersRef.doc(customer.id).update(customer.toMap());
    } catch (e) {
      debugPrint('Update customer error: $e');
      rethrow;
    }
  }

  static Future<void> deleteCustomer(String customerId) async {
    try {
      await customersRef.doc(customerId).delete();
    } catch (e) {
      debugPrint('Delete customer error: $e');
      rethrow;
    }
  }

  static Stream<List<Customer>> getAllCustomers() {
    return customersRef
        .orderBy('totalPurchases', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ==================== PURCHASE ORDERS ====================
  static CollectionReference<PurchaseOrder> get purchaseOrdersRef =>
      _firestore
          .collection(purchaseOrdersCollection)
          .withConverter<PurchaseOrder>(
            fromFirestore: (snapshot, _) =>
                PurchaseOrder.fromMap(snapshot.data()!),
            toFirestore: (order, _) => order.toMap(),
          );

  static Future<void> addPurchaseOrder(PurchaseOrder order) async {
    try {
      await purchaseOrdersRef.doc(order.id).set(order);
    } catch (e) {
      debugPrint('Add purchase order error: $e');
      rethrow;
    }
  }

  static Future<void> updatePurchaseOrder(PurchaseOrder order) async {
    try {
      await purchaseOrdersRef.doc(order.id).update(order.toMap());
    } catch (e) {
      debugPrint('Update purchase order error: $e');
      rethrow;
    }
  }

  static Future<void> deletePurchaseOrder(String orderId) async {
    try {
      await purchaseOrdersRef.doc(orderId).delete();
    } catch (e) {
      debugPrint('Delete purchase order error: $e');
      rethrow;
    }
  }

  static Stream<List<PurchaseOrder>> getAllPurchaseOrders() {
    return purchaseOrdersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Stream<List<PurchaseOrder>> getPurchaseOrdersByStatus(
    String status,
  ) {
    return purchaseOrdersRef
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ==================== STATISTICS ====================
  static Future<double> getTotalInventoryValue() async {
    try {
      final snapshot = await productsRef.get();
      double total = 0.0;
      for (final doc in snapshot.docs) {
        final product = doc.data();
        total += product.totalValue;
      }
      return total;
    } catch (e) {
      debugPrint('Get total inventory value error: $e');
      return 0.0;
    }
  }

  static Future<double> getTodayRevenue() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Convert DateTime to Timestamp for Firestore query
      final startTimestamp = Timestamp.fromDate(startOfDay);
      final endTimestamp = Timestamp.fromDate(endOfDay);

      final snapshot = await invoicesRef
          .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
          .where('createdAt', isLessThan: endTimestamp)
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final invoice = doc.data();
        total += invoice.total;
      }
      
      debugPrint('FirestoreService.getTodayRevenue: Found ${snapshot.docs.length} invoices, total: $total');
      return total;
    } catch (e) {
      debugPrint('Get today revenue error: $e');
      debugPrint('Error details: ${e.toString()}');
      // If query fails (e.g., missing composite index), return 0
      // The InvoiceProvider will calculate from loaded invoices instead
      return 0.0;
    }
  }

  static Future<Map<String, int>> getProductSalesCount() async {
    try {
      final Map<String, int> salesCount = {};
      final snapshot = await invoicesRef.get();
      for (final doc in snapshot.docs) {
        final invoice = doc.data();
        for (final item in invoice.items) {
          salesCount[item.productId] =
              (salesCount[item.productId] ?? 0) + item.quantity;
        }
      }
      return salesCount;
    } catch (e) {
      debugPrint('Get product sales count error: $e');
      return {};
    }
  }
}

