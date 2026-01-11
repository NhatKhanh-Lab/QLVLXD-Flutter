import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';
import 'product_list_screen.dart';
import 'invoice_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'supplier_list_screen.dart';
import 'customer_list_screen.dart';
import 'purchase_order_list_screen.dart';
import 'transaction_history_screen.dart';
import 'low_stock_products_screen.dart';

// Color constants for this screen
const Color _kAccentBlue = Color(0xFF3B82F6);
const Color _kAccentAmber = Color(0xFFF59E0B);
const Color _kSuccessColor = Color(0xFF22C55E);
const Color _kWarningColor = Color(0xFFF97316);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Chủ'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Data automatically updates via Firestore streams
          // No need to manually reload
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
            children: [
            _buildKpiSection(context, productProvider),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Thao Tác Nhanh'),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Tổng Quan Tài Chính'),
            const SizedBox(height: 16),
            _buildFinancialSummary(context, invoiceProvider),
            const SizedBox(height: 24),
            if (productProvider.lowStockProducts.isNotEmpty)
              _buildLowStockSection(context, productProvider),
          ],
                  ),
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context, ProductProvider productProvider) {
    return Row(
                children: [
                  Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductListScreen()),
              );
            },
            child: _KpiCard(
              label: 'Tổng Sản Phẩm',
              value: productProvider.allProducts.length.toString(),
              icon: Icons.inventory_2_outlined,
              accentColor: _kAccentBlue,
            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                  builder: (_) => const LowStockProductsScreen(),
                        ),
                      );
                    },
            child: _KpiCard(
              label: 'Tồn Kho Thấp',
              value: productProvider.lowStockProducts.length.toString(),
              icon: Icons.warning_amber_rounded,
              accentColor: _kAccentAmber,
            ),
          ),
                  ),
                ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
                children: [
        _QuickActionTile(
          icon: Icons.inventory_2_outlined,
          label: 'Sản Phẩm',
          color: const Color(0xFF2F80ED),
          onTap: () => Navigator.push(
                        context,
            MaterialPageRoute(builder: (_) => const ProductListScreen()),
                        ),
                  ),
        _QuickActionTile(
          icon: Icons.receipt_long_outlined,
          label: 'Hóa Đơn',
          color: const Color(0xFFF2994A),
          onTap: () => Navigator.push(
                        context,
            MaterialPageRoute(builder: (_) => const InvoiceScreen()),
                        ),
                  ),
        _QuickActionTile(
          icon: Icons.local_shipping_outlined,
          label: 'Nhà C.Cấp',
          color: const Color(0xFF9B51E0),
          onTap: () => Navigator.push(
                        context,
            MaterialPageRoute(builder: (_) => const SupplierListScreen()),
                        ),
                  ),
        _QuickActionTile(
          icon: Icons.people_alt_outlined,
          label: 'K.Hàng',
          color: const Color(0xFF2D9CDB),
          onTap: () => Navigator.push(
                        context,
            MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                        ),
                  ),
        _QuickActionTile(
          icon: Icons.input_outlined,
          label: 'Nhập Hàng',
          color: const Color(0xFF27AE60),
          onTap: () => Navigator.push(
                        context,
            MaterialPageRoute(builder: (_) => const PurchaseOrderListScreen()),
                        ),
                  ),
        _QuickActionTile(
          icon: Icons.history_outlined,
          label: 'Lịch Sử GD',
          color: const Color(0xFF4F4F4F),
          onTap: () => Navigator.push(
                        context,
            MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                        ),
                  ),
        _QuickActionTile(
          icon: Icons.bar_chart_rounded,
          label: 'Thống Kê',
          color: const Color(0xFF1F4FD8),
          onTap: () => Navigator.push(
                        context,
            MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                        ),
                  ),
        _QuickActionTile(
          icon: Icons.settings_outlined,
          label: 'Cài Đặt',
          color: const Color(0xFF828282),
          onTap: () => Navigator.push(
                        context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
                  ),
                ],
    );
  }

  Widget _buildFinancialSummary(BuildContext context, InvoiceProvider invoiceProvider) {
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: FutureBuilder<double>(
                future: invoiceProvider.getTodayRevenue(),
                builder: (context, snapshot) {
                  final todayRevenue = snapshot.data ?? 0.0;
                  return _FinancialStat(
                    label: 'Doanh Thu Hôm Nay',
                    value: '${currencyFormat.format(todayRevenue)} VND',
                    color: _kSuccessColor,
                  );
                },
              ),
            ),
            Container(width: 1, height: 40, color: Colors.grey[200]),
            Expanded(
              child: _FinancialStat(
                label: 'Tổng Doanh Thu',
                value: '${currencyFormat.format(invoiceProvider.getTotalRevenue())} VND',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection(BuildContext context, ProductProvider productProvider) {
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Cảnh Báo Tồn Kho Thấp'),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: productProvider.lowStockProducts.length > 5 ? 5 : productProvider.lowStockProducts.length,
          itemBuilder: (context, index) {
            final product = productProvider.lowStockProducts[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: _kWarningColor),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Chỉ còn: ${product.quantity} ${product.unit}'),
                trailing: _PriceChip(price: product.price, formatter: currencyFormat),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ],
    );
  }
}

// --- REUSABLE WIDGETS FOR DASHBOARD ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title.toUpperCase(), style: Theme.of(context).textTheme.titleMedium);
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value; 
  final IconData icon;
  final Color accentColor;

  const _KpiCard({required this.label, required this.value, required this.icon, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [accentColor.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(left: BorderSide(color: accentColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  Icon(icon, color: accentColor, size: 24),
                ],
              ),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: accentColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
              padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
              child: Icon(icon, size: 24, color: color),
                ),
            const SizedBox(height: 6),
                Text(
              label,
              textAlign: TextAlign.center,
                  style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                    color: color,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
    );
  }
}

class _FinancialStat extends StatelessWidget {
  final String label, value; 
  final Color color;

  const _FinancialStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final double price; 
  final NumberFormat formatter;

  const _PriceChip({required this.price, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('${formatter.format(price)} VND'),
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      side: BorderSide.none,
    );
  }
}
