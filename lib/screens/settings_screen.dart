import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
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
          // Account Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tài khoản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Đăng xuất khỏi tài khoản hiện tại'),
            onTap: () => _logout(context),
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
            subtitle: Text('GKNM PROJECT - QLVLXD'),
          ),
        ],
      ),
    );
  }
}

