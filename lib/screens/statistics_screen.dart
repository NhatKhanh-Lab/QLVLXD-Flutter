import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';
import '../widgets/chart_widget.dart';
import '../services/db_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');

    // Calculate inventory by category
    final Map<String, double> categoryValues = {};
    for (final product in productProvider.allProducts) {
      categoryValues[product.category] =
          (categoryValues[product.category] ?? 0) + product.totalValue;
    }

    // Calculate daily sales (last 7 days)
    final Map<String, double> dailySales = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('dd/MM').format(date);
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final dayInvoices = invoiceProvider.getInvoicesByDateRange(
        startOfDay,
        endOfDay,
      );
      dailySales[dateStr] =
          dayInvoices.fold(0.0, (sum, inv) => sum + inv.total);
    }

    // Top selling products
    final salesCount = invoiceProvider.getProductSalesCount();
    final topProducts = salesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await productProvider.loadProducts();
          await invoiceProvider.loadInvoices();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Tổng giá trị tồn kho',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currencyFormat.format(DatabaseService.getTotalInventoryValue())} VND',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Doanh thu hôm nay',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currencyFormat.format(invoiceProvider.getTodayRevenue())} VND',
                            style: const TextStyle(
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

            const SizedBox(height: 24),

            // Inventory Chart
            if (categoryValues.isNotEmpty)
              InventoryChartWidget(categoryValues: categoryValues),

            const SizedBox(height: 24),

            // Sales Chart
            if (dailySales.isNotEmpty)
              SalesChartWidget(dailySales: dailySales),

            const SizedBox(height: 24),

            // Top Selling Products
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sản phẩm bán chạy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (topProducts.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('Chưa có dữ liệu bán hàng'),
                        ),
                      )
                    else
                      ...topProducts.take(10).toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final productSales = entry.value;
                        final product = productProvider
                            .getProductById(productSales.key);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            product?.name ?? productSales.key,
                          ),
                          subtitle: Text('Đã bán: ${productSales.value}'),
                          trailing: product != null
                              ? Text(
                                  '${currencyFormat.format(product.price)} VND',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Category Statistics
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thống kê theo danh mục',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...productProvider.categories
                        .where((cat) => cat != 'Tất cả')
                        .map((category) {
                        final products = productProvider.allProducts
                            .where((p) => p.category == category)
                            .toList();
                      final totalValue = products.fold(
                          0.0, (sum, p) => sum + p.totalValue);
                      final totalQuantity =
                          products.fold(0, (sum, p) => sum + p.quantity);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(category),
                          subtitle: Text(
                            '${products.length} sản phẩm | Tồn: $totalQuantity',
                          ),
                          trailing: Text(
                            '${currencyFormat.format(totalValue)} VND',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

