import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/purchase_order.dart';
import '../models/invoice_item.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class PurchaseOrderProvider with ChangeNotifier {
  List<PurchaseOrder> _orders = [];
  bool _isLoading = false;
  final _uuid = const Uuid();
  StreamSubscription<List<PurchaseOrder>>? _ordersSubscription;

  List<PurchaseOrder> get orders => _orders;
  bool get isLoading => _isLoading;

  PurchaseOrderProvider() {
    _loadOrders();
  }

  void _loadOrders() {
    _isLoading = true;
    notifyListeners();

    final stream = FirestoreService.getAllPurchaseOrders();

    _ordersSubscription = stream.listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading purchase orders from Firestore: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
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
      await FirestoreService.addPurchaseOrder(order);
      // No need to reload - stream will automatically update
      return order;
    } catch (e) {
      debugPrint('Error creating purchase order: $e');
      rethrow;
    }
  }

  Future<void> receiveOrder(String orderId) async {
    try {
      final order = _orders.firstWhere((o) => o.id == orderId);
      final updatedOrder = order.copyWith(
        status: 'received',
        receivedDate: DateTime.now(),
      );
      await FirestoreService.updatePurchaseOrder(updatedOrder);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error receiving order: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final order = _orders.firstWhere((o) => o.id == orderId);
      final updatedOrder = order.copyWith(status: 'cancelled');
      await FirestoreService.updatePurchaseOrder(updatedOrder);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      rethrow;
    }
  }

  List<PurchaseOrder> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }
}

