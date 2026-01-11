import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// InvoiceProvider using Firestore - replaces Hive completely
/// 
/// **Key differences from Hive:**
/// - Uses Firestore streams for real-time updates
/// - Automatically filters invoices by user role (employee sees only their invoices)
/// - Data automatically syncs across all devices
class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  final _uuid = const Uuid();
  StreamSubscription<List<Invoice>>? _invoicesSubscription;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;

  InvoiceProvider() {
    _initInvoicesStream();
  }

  /// Initialize Firestore stream - automatically updates when data changes
  void _initInvoicesStream() {
    _isLoading = true;
    notifyListeners();

    // Listen to Firestore stream - automatically updates UI when data changes
    // Note: We'll need to pass AuthProvider context to filter by user
    _invoicesSubscription = FirestoreService.getAllInvoices().listen(
      (invoices) {
        _invoices = invoices;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading invoices from Firestore: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Update stream based on current user (for role-based filtering)
  void updateStreamForUser(String? userId, bool isAdmin) {
    _invoicesSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    // If employee, only show their invoices. If admin, show all
    final stream = isAdmin
        ? FirestoreService.getAllInvoices()
        : (userId != null
            ? FirestoreService.getInvoicesByUser(userId)
            : FirestoreService.getAllInvoices());

    _invoicesSubscription = stream.listen(
      (invoices) {
        _invoices = invoices;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading invoices from Firestore: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _invoicesSubscription?.cancel();
    super.dispose();
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
    required String? createdBy, // User ID who creates this invoice
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
      createdBy: createdBy, // Track who created this invoice
    );

    try {
      // Add to Firestore - automatically syncs to all devices
      await FirestoreService.addInvoice(invoice);
      // No need to reload - stream will automatically update
      return invoice;
    } catch (e) {
      debugPrint('Error creating invoice: $e');
      rethrow;
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      // Delete from Firestore - automatically syncs to all devices
      await FirestoreService.deleteInvoice(invoiceId);
      // No need to reload - stream will automatically update
    } catch (e) {
      debugPrint('Error deleting invoice: $e');
      rethrow;
    }
  }

  Future<List<Invoice>> getInvoicesByDateRange(DateTime start, DateTime end) async {
    // Wait a bit for invoices to load if they're still loading
    int retries = 0;
    while (_isLoading && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      retries++;
    }
    
    // Filter from already loaded invoices (respects user role filtering)
    // This ensures consistency with what user sees in invoice screen
    // Use >= and < for proper date range filtering
    final filtered = _invoices.where((invoice) {
      final createdAt = invoice.createdAt;
      return (createdAt.isAfter(start) || createdAt.isAtSameMomentAs(start)) &&
             createdAt.isBefore(end);
    }).toList();
    
    debugPrint('getInvoicesByDateRange: Found ${filtered.length} invoices between ${start.toIso8601String()} and ${end.toIso8601String()}');
    debugPrint('Total invoices in memory: ${_invoices.length}');
    if (_invoices.isEmpty) {
      debugPrint('WARNING: No invoices loaded yet! Statistics may be incorrect.');
    } else {
      // Debug: show sample invoice dates
      debugPrint('Sample invoice dates:');
      for (var inv in _invoices.take(3)) {
        debugPrint('  - ${inv.invoiceNumber}: ${inv.createdAt.toIso8601String()}, total: ${inv.total}');
      }
    }
    
    return filtered;
  }

  Future<double> getTodayRevenue() async {
    // Wait a bit for invoices to load if they're still loading
    int retries = 0;
    while (_isLoading && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      retries++;
    }
    
    // Calculate from already loaded invoices (respects user role filtering)
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    debugPrint('getTodayRevenue: Filtering invoices from ${startOfDay.toIso8601String()} to ${endOfDay.toIso8601String()}');
    
    final todayInvoices = _invoices.where((invoice) {
      final createdAt = invoice.createdAt;
      return (createdAt.isAfter(startOfDay) || createdAt.isAtSameMomentAs(startOfDay)) &&
             createdAt.isBefore(endOfDay);
    }).toList();
    
    final revenue = todayInvoices.fold(0.0, (sum, invoice) => sum + invoice.total);
    
    debugPrint('getTodayRevenue: Found ${todayInvoices.length} invoices today, revenue: $revenue');
    debugPrint('Total invoices in memory: ${_invoices.length}');
    if (_invoices.isEmpty) {
      debugPrint('WARNING: No invoices loaded yet! Statistics may be incorrect.');
    } else {
      // Debug: show today's invoices
      if (todayInvoices.isNotEmpty) {
        debugPrint('Today\'s invoices:');
        for (var inv in todayInvoices) {
          debugPrint('  - ${inv.invoiceNumber}: ${inv.createdAt.toIso8601String()}, total: ${inv.total}');
        }
      } else {
        debugPrint('No invoices found for today. Sample invoice dates:');
        for (var inv in _invoices.take(5)) {
          debugPrint('  - ${inv.invoiceNumber}: ${inv.createdAt.toIso8601String()}, total: ${inv.total}');
        }
      }
    }
    
    return revenue;
  }

  double getTotalRevenue() {
    return _invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  Future<Map<String, int>> getProductSalesCount() async {
    return await FirestoreService.getProductSalesCount();
  }
}

