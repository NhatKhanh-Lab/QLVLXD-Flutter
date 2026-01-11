import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart' as app_user;
import '../providers/auth_provider.dart';
import '../services/firebase_auth_service.dart';
import 'add_edit_user_screen.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Only admin can access
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý Nhân viên')),
        body: const Center(
          child: Text('Bạn không có quyền truy cập'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhân viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditUserScreen(),
                ),
              );
            },
            tooltip: 'Thêm nhân viên',
          ),
        ],
      ),
      body: StreamBuilder<List<app_user.User>>(
        stream: FirebaseAuthService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có nhân viên',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isAdmin
                        ? Colors.blue
                        : Colors.green,
                    child: Icon(
                      user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${user.username}'),
                      Text(user.email),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: user.isAdmin
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.isAdmin ? 'Admin' : 'Nhân viên',
                              style: TextStyle(
                                fontSize: 12,
                                color: user.isAdmin ? Colors.blue : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!user.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Vô hiệu hóa',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Sửa'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: user.isActive ? 'disable' : 'enable',
                        child: Row(
                          children: [
                            Icon(
                              user.isActive ? Icons.block : Icons.check_circle,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
                          ],
                        ),
                      ),
                      if (user.id != authProvider.currentUser?.id)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditUserScreen(user: user),
                          ),
                        );
                      } else if (value == 'disable' || value == 'enable') {
                        final updatedUser = user.copyWith(
                          isActive: value == 'enable',
                          updatedAt: DateTime.now(),
                        );
                        await FirebaseAuthService.updateUser(updatedUser);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value == 'enable'
                                    ? 'Đã kích hoạt nhân viên'
                                    : 'Đã vô hiệu hóa nhân viên',
                              ),
                            ),
                          );
                        }
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text(
                              'Bạn có chắc chắn muốn xóa nhân viên ${user.fullName}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirebaseAuthService.deleteUser(user.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa nhân viên'),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

