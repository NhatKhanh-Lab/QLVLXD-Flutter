import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'add_edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Sản Phẩm'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined),
            tooltip: _isGridView ? 'Xem dạng danh sách' : 'Xem dạng lưới',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(
            children: [
              _buildSearchAndFilter(productProvider),
              Expanded(
                child: productProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : productProvider.products.isEmpty
                        ? _buildEmptyState()
                        : _buildProductList(productProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndShowSnackBar(context, const AddEditProductScreen()),
        tooltip: 'Thêm sản phẩm',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter(ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm theo tên hoặc danh mục...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: provider.setSearchQuery,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return FilterChip(
                  label: Text(category),
                  selected: provider.selectedCategory == category,
                  onSelected: (_) => provider.setCategory(category),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
            ),
          ),
        ],
            ),
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sản phẩm',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử thay đổi bộ lọc hoặc thêm sản phẩm mới.',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(ProductProvider provider) {
    final products = provider.products;
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => _buildProductCard(context, products[index]),
      );
    }
    // For list view, wrap ProductCard in a SizedBox to constrain its height
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: SizedBox(
          height: 280, // Constrain height in list view
          child: _buildProductCard(context, products[index]),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, product) {
    return ProductCard(
      product: product,
      onTap: () { /* Handle tap if needed, e.g., view details */ },
      onEdit: () => _navigateAndShowSnackBar(context, AddEditProductScreen(product: product)),
      onDelete: () => _showDeleteDialog(context, product),
    );
  }

  Future<void> _navigateAndShowSnackBar(BuildContext context, Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (result is Map<String, dynamic> && mounted) {
      _showResultSnackBar(result);
    }
  }

  void _showDeleteDialog(BuildContext context, product) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await provider.deleteProduct(product.id);
                if (mounted) {
                  _showResultSnackBar({'success': true, 'message': 'Đã xóa sản phẩm thành công'});
                }
              } catch (e) {
                if (mounted) {
                  _showResultSnackBar({'success': false, 'message': 'Lỗi khi xóa: $e'});
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
            child: Text('Xóa', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }

  void _showResultSnackBar(Map<String, dynamic> result) {
    final bool success = result['success'] ?? false;
    final String message = result['message'] ?? 'Thao tác không rõ kết quả.';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? const Color(0xFF22C55E) : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
