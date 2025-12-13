import 'package:flutter/foundation.dart';
import '../models/purchase_order.dart';
import '../models/invoice_item.dart';
import '../services/db_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class PurchaseOrderProvider with ChangeNotifier {
  List<PurchaseOrder> _orders = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  List<PurchaseOrder> get orders => _orders;
  bool get isLoading => _isLoading;

  PurchaseOrderProvider() {
    loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = DatabaseService.getAllPurchaseOrders();
      _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    } catch (e) {
      debugPrint('Error loading purchase orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final count = _orders
        .where((order) => order.orderDate.year == now.year &&
            order.orderDate.month == now.month &&
            order.orderDate.day == now.day)
        .length;
    return 'PN$dateStr${(count + 1).toString().padLeft(4, '0')}';
  }

  Future<PurchaseOrder> createPurchaseOrder({
    required String supplierId,
    required String? supplierName,
    required List<InvoiceItem> items,
    String? notes,
  }) async {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    final total = subtotal;

    final order = PurchaseOrder(
      id: _uuid.v4(),
      orderNumber: _generateOrderNumber(),
      supplierId: supplierId,
      supplierName: supplierName,
      items: items,
      subtotal: subtotal,
      total: total,
      orderDate: DateTime.now(),
      status: 'pending',
      notes: notes,
      createdAt: DateTime.now(),
    );

    try {
      await DatabaseService.addPurchaseOrder(order);
      await loadOrders();
      return order;
    } catch (e) {
      debugPrint('Error creating purchase order: $e');
      rethrow;
    }
  }

  Future<void> receiveOrder(String orderId) async {
    try {
      final order = DatabaseService.getPurchaseOrder(orderId);
      if (order != null) {
        final updatedOrder = order.copyWith(
          status: 'received',
          receivedDate: DateTime.now(),
        );
        await DatabaseService.updatePurchaseOrder(updatedOrder);
        await loadOrders();
      }
    } catch (e) {
      debugPrint('Error receiving order: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final order = DatabaseService.getPurchaseOrder(orderId);
      if (order != null) {
        final updatedOrder = order.copyWith(status: 'cancelled');
        await DatabaseService.updatePurchaseOrder(updatedOrder);
        await loadOrders();
      }
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      rethrow;
    }
  }

  List<PurchaseOrder> getOrdersByStatus(String status) {
    return DatabaseService.getPurchaseOrdersByStatus(status);
  }
}

