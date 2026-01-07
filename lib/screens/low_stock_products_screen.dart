import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'add_edit_product_screen.dart';

class LowStockProductsScreen extends StatelessWidget {
  const LowStockProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tồn Kho Thấp'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final lowStock = productProvider.lowStockProducts;

          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lowStock.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không có sản phẩm tồn kho thấp',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Dùng grid giống trang sản phẩm để quen UX
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: lowStock.length,
            itemBuilder: (context, index) {
              final product = lowStock[index];
              return ProductCard(
                product: product,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditProductScreen(product: product),
                    ),
                  );
                },
                onDelete: () async {
                  // Reuse delete behavior from ProductProvider
                  final provider = Provider.of<ProductProvider>(context, listen: false);
                  await provider.deleteProduct(product.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa sản phẩm'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
        },
        tooltip: 'Thêm sản phẩm',
        child: const Icon(Icons.add),
      ),
    );
  }
}


