import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import 'db_service.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String productsCollection = 'products';
  static const String invoicesCollection = 'invoices';

  // Initialize Firebase (call this in main.dart if using Firebase)
  static Future<void> init() async {
    await Firebase.initializeApp();
  }

  // Product sync
  static Future<void> syncProductToFirebase(Product product) async {
    try {
      // Check if Firebase is initialized
      // If not initialized, silently skip (app works offline)
      await _firestore
          .collection(productsCollection)
          .doc(product.id)
          .set(product.toMap());
    } catch (e) {
      // Silently fail if Firebase is not configured
      // App continues to work offline
      debugPrint('Firebase sync skipped: $e');
    }
  }

  static Future<void> deleteProductFromFirebase(String productId) async {
    try {
      await _firestore.collection(productsCollection).doc(productId).delete();
    } catch (e) {
      debugPrint('Firebase delete skipped: $e');
    }
  }

  static Future<List<Product>> fetchProductsFromFirebase() async {
    try {
      final snapshot = await _firestore.collection(productsCollection).get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Firebase fetch skipped: $e');
      return [];
    }
  }

  // Invoice sync
  static Future<void> syncInvoiceToFirebase(Invoice invoice) async {
    try {
      await _firestore
          .collection(invoicesCollection)
          .doc(invoice.id)
          .set(invoice.toMap());
    } catch (e) {
      debugPrint('Firebase sync skipped: $e');
    }
  }

  static Future<List<Invoice>> fetchInvoicesFromFirebase() async {
    try {
      final snapshot = await _firestore.collection(invoicesCollection).get();
      return snapshot.docs
          .map((doc) => Invoice.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Firebase fetch skipped: $e');
      return [];
    }
  }

  // Sync all data
  static Future<void> syncAllToFirebase() async {
    // Sync products
    final products = DatabaseService.getAllProducts();
    for (final product in products) {
      await syncProductToFirebase(product);
    }

    // Sync invoices
    final invoices = DatabaseService.getAllInvoices();
    for (final invoice in invoices) {
      await syncInvoiceToFirebase(invoice);
    }
  }

  // Restore from Firebase
  static Future<void> restoreFromFirebase() async {
    // Fetch and import products
    final products = await fetchProductsFromFirebase();
    for (final product in products) {
      await DatabaseService.addProduct(product);
    }

    // Fetch and import invoices
    final invoices = await fetchInvoicesFromFirebase();
    for (final invoice in invoices) {
      await DatabaseService.addInvoice(invoice);
    }
  }
}

