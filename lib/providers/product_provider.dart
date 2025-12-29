import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/db_service.dart';
import '../services/firebase_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  bool _isLoading = false;

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
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = DatabaseService.getAllProducts();
      _products.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Error loading products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      await DatabaseService.addProduct(product);
      await FirebaseService.syncProductToFirebase(product);
      await loadProducts();
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await DatabaseService.updateProduct(product);
      await FirebaseService.syncProductToFirebase(product);
      await loadProducts();
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await DatabaseService.deleteProduct(productId);
      await FirebaseService.deleteProductFromFirebase(productId);
      // Xóa sản phẩm khỏi list hiện tại và thông báo thay đổi
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
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

  void updateProductQuantity(String productId, int quantityChange) {
    final product = getProductById(productId);
    if (product != null) {
      final updatedProduct = product.copyWith(
        quantity: product.quantity + quantityChange,
        updatedAt: DateTime.now(),
      );
      updateProduct(updatedProduct);
    }
  }
}

