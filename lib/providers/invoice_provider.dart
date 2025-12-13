import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/db_service.dart';
import '../services/firebase_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;

  InvoiceProvider() {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _invoices = DatabaseService.getAllInvoices();
      _invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading invoices: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final count = _invoices
        .where((inv) => inv.createdAt.year == now.year &&
            inv.createdAt.month == now.month &&
            inv.createdAt.day == now.day)
        .length;
    return 'HD$dateStr${(count + 1).toString().padLeft(4, '0')}';
  }

  Future<Invoice> createInvoice({
    required List<InvoiceItem> items,
    double vatRate = 0.1,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    final vat = subtotal * vatRate;
    final total = subtotal + vat;

    final invoice = Invoice(
      id: _uuid.v4(),
      invoiceNumber: _generateInvoiceNumber(),
      items: items,
      subtotal: subtotal,
      vat: vat,
      total: total,
      customerName: customerName,
      customerPhone: customerPhone,
      createdAt: DateTime.now(),
      notes: notes,
    );

    try {
      await DatabaseService.addInvoice(invoice);
      await FirebaseService.syncInvoiceToFirebase(invoice);
      await loadInvoices();
      return invoice;
    } catch (e) {
      debugPrint('Error creating invoice: $e');
      rethrow;
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await DatabaseService.deleteInvoice(invoiceId);
      await loadInvoices();
    } catch (e) {
      debugPrint('Error deleting invoice: $e');
      rethrow;
    }
  }

  List<Invoice> getInvoicesByDateRange(DateTime start, DateTime end) {
    return DatabaseService.getInvoicesByDateRange(start, end);
  }

  double getTodayRevenue() {
    return DatabaseService.getTodayRevenue();
  }

  double getTotalRevenue() {
    return _invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  Map<String, int> getProductSalesCount() {
    return DatabaseService.getProductSalesCount();
  }
}

