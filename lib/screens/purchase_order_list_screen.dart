import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/purchase_order_provider.dart';
import '../providers/supplier_provider.dart';
import '../providers/product_provider.dart';
import '../models/purchase_order.dart';
import 'create_purchase_order_screen.dart';

class PurchaseOrderListScreen extends StatelessWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đơn nhập hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<PurchaseOrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có đơn nhập hàng nào',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];
              Color statusColor;
              IconData statusIcon;
              String statusText;

              switch (order.status) {
                case 'pending':
                  statusColor = Colors.orange;
                  statusIcon = Icons.pending;
                  statusText = 'Chờ nhận';
                  break;
                case 'received':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  statusText = 'Đã nhận';
                  break;
                case 'cancelled':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  statusText = 'Đã hủy';
                  break;
                default:
                  statusColor = Colors.grey;
                  statusIcon = Icons.help;
                  statusText = order.status;
              }

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
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  title: Text(
                    order.orderNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (order.supplierName != null)
                        Text('NCC: ${order.supplierName}'),
                      Text('Ngày: ${dateFormat.format(order.orderDate)}'),
                      Text('${order.items.length} sản phẩm'),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(order.total),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Show order details
                    _showOrderDetails(context, order, currencyFormat, dateFormat);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePurchaseOrderScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo đơn nhập hàng'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showOrderDetails(
    BuildContext context,
    PurchaseOrder order,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(order.orderNumber),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nhà cung cấp: ${order.supplierName ?? "N/A"}'),
              Text('Ngày đặt: ${dateFormat.format(order.orderDate)}'),
              if (order.receivedDate != null)
                Text('Ngày nhận: ${dateFormat.format(order.receivedDate!)}'),
              Text('Trạng thái: ${order.status}'),
              const SizedBox(height: 16),
              const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${item.productName} x ${item.quantity} = ${currencyFormat.format(item.total)}',
                    ),
                  )),
              const Divider(),
              Text(
                'Tổng: ${currencyFormat.format(order.total)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

