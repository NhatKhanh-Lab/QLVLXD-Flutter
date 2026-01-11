import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/purchase_order_provider.dart';
import '../providers/supplier_provider.dart';
import '../providers/product_provider.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';

class CreatePurchaseOrderScreen extends StatefulWidget {
  const CreatePurchaseOrderScreen({super.key});

  @override
  State<CreatePurchaseOrderScreen> createState() => _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends State<CreatePurchaseOrderScreen> {
  final List<InvoiceItem> _items = [];
  String? _selectedSupplierId;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addProduct() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final products = productProvider.allProducts;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có sản phẩm nào. Vui lòng thêm sản phẩm trước.')),
      );
      return;
    }

    // Show product selection dialog
    showDialog(
      context: context,
      builder: (context) => _ProductSelectionDialog(
        products: products,
        onProductSelected: (product, quantity) {
          final existingItemIndex = _items.indexWhere((item) => item.productId == product.id);
          
          if (existingItemIndex >= 0) {
            // Update existing item
            setState(() {
              final existingItem = _items[existingItemIndex];
              final newQuantity = existingItem.quantity + quantity;
              _items[existingItemIndex] = InvoiceItem(
                productId: product.id,
                productName: product.name,
                unitPrice: product.price,
                quantity: newQuantity,
                total: product.price * newQuantity,
              );
            });
          } else {
            // Add new item
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
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _createOrder() async {
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn nhà cung cấp')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm sản phẩm')),
      );
      return;
    }

    try {
      final orderProvider = Provider.of<PurchaseOrderProvider>(context, listen: false);
      final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
      final supplier = supplierProvider.getSupplierById(_selectedSupplierId!);

      await orderProvider.createPurchaseOrder(
        supplierId: _selectedSupplierId!,
        supplierName: supplier?.name,
        items: _items,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo đơn nhập hàng')),
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

  double _calculateTotal() {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');
    final total = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn nhập hàng'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Consumer<SupplierProvider>(
                  builder: (context, supplierProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: _selectedSupplierId,
                      decoration: const InputDecoration(
                        labelText: 'Nhà cung cấp *',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      items: supplierProvider.suppliers.map((supplier) {
                        return DropdownMenuItem(
                          value: supplier.id,
                          child: Text(supplier.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupplierId = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sản phẩm',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm sản phẩm'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Chưa có sản phẩm nào')),
                    ),
                  )
                else
                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    // Get product to show unit
                    final product = productProvider.getProductById(item.productId);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(item.productName),
                        subtitle: Text(
                          '${item.quantity} ${product?.unit ?? ''} × ${currencyFormat.format(item.unitPrice)} VND',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${currencyFormat.format(item.total)} VND',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                if (_items.isNotEmpty) ...[
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng tiền:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${currencyFormat.format(total)} VND',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Tạo đơn nhập hàng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Product Selection Dialog
class _ProductSelectionDialog extends StatefulWidget {
  final List<Product> products;
  final Function(Product product, int quantity) onProductSelected;

  const _ProductSelectionDialog({
    required this.products,
    required this.onProductSelected,
  });

  @override
  State<_ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<_ProductSelectionDialog> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  Product? _selectedProduct;
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = widget.products
          .where((product) =>
              product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query))
          .toList();
    });
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _quantityController.text = '1';
    });
  }

  void _confirmSelection() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số lượng phải lớn hơn 0')),
      );
      return;
    }

    widget.onProductSelected(_selectedProduct!, quantity);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');

    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Chọn sản phẩm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Tìm kiếm sản phẩm',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Product List
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(child: Text('Không tìm thấy sản phẩm'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isSelected = _selectedProduct?.id == product.id;

                        return ListTile(
                          selected: isSelected,
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? Colors.blue : Colors.grey,
                            child: Text(
                              product.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.category} | Tồn: ${product.quantity} ${product.unit}',
                          ),
                          trailing: Text(
                            '${currencyFormat.format(product.price)} VND',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () => _selectProduct(product),
                        );
                      },
                    ),
            ),

            // Selected Product & Quantity
            if (_selectedProduct != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Sản phẩm: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_selectedProduct!.name),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Số lượng: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${_selectedProduct!.unit}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      child: const Text('Thêm'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
