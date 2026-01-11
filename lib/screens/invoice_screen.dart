import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice_item.dart';
import '../models/customer.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/invoice_item_widget.dart';
import '../services/pdf_service.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final List<InvoiceItem> _items = [];
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCustomerId; // Store selected customer ID
  double _vatRate = 0.1;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addProductToInvoice() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => _ProductSelectionDialog(
        products: productProvider.allProducts,
        dialogContext: dialogContext,
        onProductSelected: (product, quantity) {
          if (quantity > product.quantity) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Số lượng không đủ. Tồn kho: ${product.quantity} ${product.unit}'),
              ),
            );
            return;
          }

          final existingIndex = _items.indexWhere(
            (item) => item.productId == product.id,
          );

          if (existingIndex >= 0) {
            final existingItem = _items[existingIndex];
            final newQuantity = existingItem.quantity + quantity;
            if (newQuantity > product.quantity) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Số lượng không đủ. Tồn kho: ${product.quantity} ${product.unit}'),
                ),
              );
              return;
            }
            setState(() {
              _items[existingIndex] = InvoiceItem(
                productId: product.id,
                productName: product.name,
                unitPrice: product.price,
                quantity: newQuantity,
                total: product.price * newQuantity,
              );
            });
          } else {
            setState(() {
              _items.add(InvoiceItem(
                productId: product.id,
                productName: product.name,
                unitPrice: product.price,
                quantity: quantity,
                total: product.price * quantity,
              ));
            });
          }
          // Đóng dialog chọn sản phẩm
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _selectCustomer(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final customers = customerProvider.customers;

    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có khách hàng nào. Vui lòng thêm khách hàng trước.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chọn khách hàng'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'K',
                  ),
                ),
                title: Text(customer.name),
                subtitle: customer.phone != null
                    ? Text('SĐT: ${customer.phone}')
                    : null,
                onTap: () {
                  // Auto-fill customer info and store customer ID
                  setState(() {
                    _customerNameController.text = customer.name;
                    _customerPhoneController.text = customer.phone ?? '';
                    _selectedCustomerId = customer.id; // Store customer ID
                  });
                  Navigator.pop(dialogContext);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  void _editItem(int index) {
    final item = _items[index];
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.getProductById(item.productId);

    if (product == null) return;

    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa số lượng'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Số lượng (Tồn: ${product.quantity} ${product.unit})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (quantity > 0 && quantity <= product.quantity) {
                setState(() {
                  _items[index] = InvoiceItem(
                    productId: product.id,
                    productName: product.name,
                    unitPrice: product.price,
                    quantity: quantity,
                    total: product.price * quantity,
                  );
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Số lượng không hợp lệ')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _createInvoice() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm sản phẩm vào hóa đơn')),
      );
      return;
    }

    try {
      final invoiceProvider =
          Provider.of<InvoiceProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      // Get current user ID
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.id;

      // Create invoice
      final invoice = await invoiceProvider.createInvoice(
        items: _items,
        createdBy: currentUserId, // Track who created this invoice
        vatRate: _vatRate,
        customerName: _customerNameController.text.trim().isEmpty
            ? null
            : _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim().isEmpty
            ? null
            : _customerPhoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // Update customer total purchases if customer was selected
      if (_selectedCustomerId != null && _selectedCustomerId!.isNotEmpty) {
        final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
        customerProvider.updateCustomerTotalPurchases(_selectedCustomerId!, invoice.total);
      }

      // Update product quantities
      for (final item in _items) {
        productProvider.updateProductQuantity(item.productId, -item.quantity);
      }

      // Generate PDF
      await PDFService.generateAndPrintInvoice(invoice);

      // Clear form
      setState(() {
        _items.clear();
        _customerNameController.clear();
        _customerPhoneController.clear();
        _notesController.clear();
        _selectedCustomerId = null; // Clear selected customer ID
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo hóa đơn thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  double _calculateSubtotal() {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  double _calculateVAT() {
    return _calculateSubtotal() * _vatRate;
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateVAT();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tạo hóa đơn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử hóa đơn',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _InvoiceHistoryDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Customer Info
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Thông tin khách hàng',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search),
                              tooltip: 'Chọn khách hàng',
                              onPressed: () => _selectCustomer(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _customerNameController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Tên khách hàng',
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _customerNameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _customerNameController.clear();
                                        _customerPhoneController.clear();
                                        _selectedCustomerId = null; // Clear selected customer ID
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _customerPhoneController,
                          decoration: InputDecoration(
                            labelText: 'Số điện thoại',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_items.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_items.length}',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _addProductToInvoice,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Thêm sản phẩm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (_items.isEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có sản phẩm nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nhấn "Thêm sản phẩm" để bắt đầu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return InvoiceItemWidget(
                      item: item,
                      onEdit: () => _editItem(index),
                      onRemove: () => _removeItem(index),
                    );
                  }),

                const SizedBox(height: 16),

                // Notes
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú',
                        prefixIcon: const Icon(Icons.note_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // VAT Rate
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt_long, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'Thuế VAT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_vatRate * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: _vatRate > 0
                                    ? () {
                                        setState(() {
                                          _vatRate =
                                              (_vatRate - 0.01).clamp(0.0, 0.2);
                                        });
                                      }
                                    : null,
                              ),
                              Expanded(
                                child: Slider(
                                  value: _vatRate,
                                  min: 0,
                                  max: 0.2,
                                  divisions: 20,
                                  activeColor: Colors.blue,
                                  onChanged: (value) {
                                    setState(() {
                                      _vatRate = value;
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: _vatRate < 0.2
                                    ? () {
                                        setState(() {
                                          _vatRate =
                                              (_vatRate + 0.01).clamp(0.0, 0.2);
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Totals
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _TotalRow(
                          label: 'Tạm tính:',
                          value: currencyFormat.format(_calculateSubtotal()),
                        ),
                        const SizedBox(height: 8),
                        _TotalRow(
                          label: 'VAT (${(_vatRate * 100).toStringAsFixed(0)}%):',
                          value: currencyFormat.format(_calculateVAT()),
                        ),
                        const Divider(height: 32),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _TotalRow(
                            label: 'TỔNG CỘNG:',
                            value: currencyFormat.format(_calculateTotal()),
                            isTotal: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Create Invoice Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createInvoice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.receipt_long, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Tạo hóa đơn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSelectionDialog extends StatelessWidget {
  final List products;
  final BuildContext dialogContext;
  final Function(dynamic product, int quantity) onProductSelected;

  const _ProductSelectionDialog({
    required this.products,
    required this.dialogContext,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn sản phẩm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text('Không có sản phẩm nào'),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: product.quantity > 0
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              child: Icon(
                                product.quantity > 0
                                    ? Icons.check
                                    : Icons.close,
                                color: product.quantity > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(product.price)}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Tồn: ${product.quantity} ${product.unit}',
                                  style: TextStyle(
                                    color: product.quantity > 0
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: product.quantity > 0
                                ? IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.blue),
                                    onPressed: () {
                                      _showQuantityDialog(
                                        context,
                                        dialogContext,
                                        product,
                                        onProductSelected,
                                      );
                                    },
                                  )
                                : null,
                            onTap: product.quantity > 0
                                ? () {
                                    _showQuantityDialog(
                                      context,
                                      dialogContext,
                                      product,
                                      onProductSelected,
                                    );
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(
    BuildContext context,
    BuildContext parentDialogContext,
    dynamic product,
    Function(dynamic product, int quantity) onProductSelected,
  ) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
        ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name
                Text(
          product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Product Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                            'Giá:',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
                          ),
                          Text(
                            NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                                .format(product.price),
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
            ),
            const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
            Text(
                            'Tồn kho:',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${product.quantity} ${product.unit}',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quantity Selector
                Text(
                  'Chọn số lượng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Decrease Button
                      IconButton(
                        onPressed: quantity > 1
                            ? () {
                                setState(() {
                                  quantity--;
                                });
                              }
                            : null,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: quantity > 1
                                ? Colors.red[100]
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.remove,
                            color: quantity > 1 ? Colors.red[700] : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),

                      // Quantity Display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),

                      // Increase Button
                      IconButton(
                        onPressed: quantity < product.quantity
                            ? () {
                                setState(() {
                                  quantity++;
                                });
                              }
                            : null,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: quantity < product.quantity
                                ? Colors.green[100]
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: quantity < product.quantity
                                ? Colors.green[700]
                                : Colors.grey,
                            size: 20,
                          ),
              ),
            ),
          ],
        ),
                ),

                const SizedBox(height: 24),

                // Total Price
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thành tiền:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                            .format(product.price * quantity),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
          ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
            onPressed: () {
              if (quantity > 0 && quantity <= product.quantity) {
                // Đóng dialog số lượng trước
                Navigator.pop(dialogContext);
                // Sau đó gọi callback để thêm sản phẩm và đóng dialog chọn sản phẩm
                onProductSelected(product, quantity);
              }
            },
            style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
            ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Xác nhận',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceHistoryDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch sử hóa đơn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: invoiceProvider.invoices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có hóa đơn nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: invoiceProvider.invoices.length,
                      itemBuilder: (context, index) {
                        final invoice = invoiceProvider.invoices[index];
                        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                        final currencyFormat =
                            NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.receipt,
                                color: Colors.green[700],
                              ),
                            ),
                            title: Text(
                              invoice.invoiceNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateFormat.format(invoice.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${invoice.items.length} sản phẩm',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormat.format(invoice.total),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                            onTap: () async {
                              await PDFService.generateAndPrintInvoice(invoice);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

