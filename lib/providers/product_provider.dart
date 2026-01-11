import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/product.dart';
import '../services/firestore_service.dart';

/// ProductProvider using Firestore - replaces Hive completely
/// 
/// **Key differences from Hive:**
/// - Uses Firestore streams for real-time updates
/// - Data automatically syncs across all devices
/// - No need to manually sync - changes appear instantly
/// - Works offline with Firestore's offline persistence
class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  bool _isLoading = false;
  StreamSubscription<List<Product>>? _productsSubscription;

  List<Product> get products {
    var filtered = _products;

    // Filter by category
    if (_selectedCategory != 'Tất cả') {
      filtered = filtered
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.category.toLowerCase().contains(lowerQuery))
          .toList();
    }

    return filtered;
  }

  List<Product> get allProducts => _products;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['Tất cả', ...cats];
  }

  List<Product> get lowStockProducts {
    return _products.where((p) => p.isLowStock).toList();
  }

  ProductProvider() {
    _initProductsStream();
  }

  /// Initialize Firestore stream - automatically updates when data changes
  void _initProductsStream() {
    _isLoading = true;
    notifyListeners();

    // Listen to Firestore stream - automatically updates UI when data changes
    _productsSubscription = FirestoreService.getAllProducts().listen(
      (products) {
        _products = products;
        _products.sort((a, b) => a.name.compareTo(b.name));
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading products from Firestore: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  Future<void> addProduct(Product product) async {
    try {
      // Add to Firestore - automatically syncs to all devices
      await FirestoreService.addProduct(product);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      // Update in Firestore - automatically syncs to all devices
      await FirestoreService.updateProduct(product);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // Delete from Firestore - automatically syncs to all devices
      await FirestoreService.deleteProduct(productId);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProductQuantity(String productId, int quantityChange) async {
    final product = getProductById(productId);
    if (product != null) {
      final updatedProduct = product.copyWith(
        quantity: product.quantity + quantityChange,
        updatedAt: DateTime.now(),
      );
      await updateProduct(updatedProduct);
    }
  }
}

