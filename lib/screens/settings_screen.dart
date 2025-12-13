import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
// Note: share_plus package needs to be added to pubspec.yaml if you want to use it
// For now, we'll comment it out
// import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../services/db_service.dart';
import '../services/firebase_service.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _backupData(BuildContext context) async {
    try {
      final data = DatabaseService.exportData();
      final jsonString = jsonEncode(data);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã sao lưu: ${file.path}')),
        );
      }

      // Share file (requires share_plus package)
      // await Share.shareXFiles([XFile(file.path)],
      //     text: 'Backup dữ liệu vật liệu xây dựng');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi sao lưu: $e')),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    // In a real app, you would use file_picker to select a file
    // For now, we'll show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục dữ liệu'),
        content: const Text(
          'Tính năng này yêu cầu chọn file backup. '
          'Vui lòng sử dụng file_picker để chọn file JSON backup.',
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

  Future<void> _syncToFirebase(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await FirebaseService.syncAllToFirebase();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đồng bộ lên Firebase')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đồng bộ: $e')),
        );
      }
    }
  }

  Future<void> _restoreFromFirebase(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await FirebaseService.restoreFromFirebase();

      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final invoiceProvider =
          Provider.of<InvoiceProvider>(context, listen: false);

      await productProvider.loadProducts();
      await invoiceProvider.loadInvoices();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã khôi phục từ Firebase')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khôi phục: $e')),
        );
      }
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả dữ liệu'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả dữ liệu? '
          'Hành động này không thể hoàn tác!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.clearAllData();

        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final invoiceProvider =
            Provider.of<InvoiceProvider>(context, listen: false);

        await productProvider.loadProducts();
        await invoiceProvider.loadInvoices();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa tất cả dữ liệu')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // Backup & Restore Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sao lưu & Khôi phục',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Sao lưu dữ liệu'),
            subtitle: const Text('Xuất dữ liệu ra file JSON'),
            onTap: () => _backupData(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Khôi phục dữ liệu'),
            subtitle: const Text('Nhập dữ liệu từ file backup'),
            onTap: () => _restoreData(context),
          ),

          const Divider(),

          // Firebase Sync Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Đồng bộ Firebase',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Đồng bộ lên Firebase'),
            subtitle: const Text('Tải dữ liệu lên cloud'),
            onTap: () => _syncToFirebase(context),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: const Text('Khôi phục từ Firebase'),
            subtitle: const Text('Tải dữ liệu từ cloud'),
            onTap: () => _restoreFromFirebase(context),
          ),

          const Divider(),

          // Danger Zone
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Vùng nguy hiểm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Xóa tất cả dữ liệu',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Xóa vĩnh viễn tất cả dữ liệu'),
            onTap: () => _clearAllData(context),
          ),

          const Divider(),

          // App Info
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Thông tin ứng dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Phiên bản'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.description),
            title: Text('Mô tả'),
            subtitle: Text('Ứng dụng quản lý và bán vật liệu xây dựng'),
          ),
        ],
      ),
    );
  }
}

