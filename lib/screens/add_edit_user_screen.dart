import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart' as app_user;
import '../providers/auth_provider.dart';
import '../services/firebase_auth_service.dart';
import 'package:uuid/uuid.dart';

class AddEditUserScreen extends StatefulWidget {
  final app_user.User? user;

  const AddEditUserScreen({super.key, this.user});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  app_user.UserRole _selectedRole = app_user.UserRole.employee;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _fullNameController.text = widget.user!.fullName;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone ?? '';
      _selectedRole = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (widget.user != null) {
        // Update existing user
        final updatedUser = widget.user!.copyWith(
          username: _usernameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          role: _selectedRole,
          updatedAt: DateTime.now(),
          password: _passwordController.text.isNotEmpty
              ? _passwordController.text
              : widget.user!.password,
        );

        await FirebaseAuthService.updateUser(updatedUser);
      } else {
        // Create new user
        final newUser = await FirebaseAuthService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          role: _selectedRole,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          createdBy: authProvider.currentUser?.id,
        );

        if (newUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể tạo tài khoản. Vui lòng thử lại.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.user != null
                  ? 'Đã cập nhật nhân viên'
                  : 'Đã tạo nhân viên mới',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Lỗi: $e';
        
        // Extract meaningful error message
        final errorStr = e.toString();
        if (errorStr.contains('Email đã tồn tại') || errorStr.contains('Email đã được sử dụng')) {
          errorMessage = errorStr.contains('Exception: ')
              ? errorStr.replaceAll('Exception: ', '')
              : 'Email đã tồn tại trong hệ thống. Vui lòng dùng email khác.';
        } else if (errorStr.contains('Tên đăng nhập đã tồn tại')) {
          errorMessage = errorStr.contains('Exception: ')
              ? errorStr.replaceAll('Exception: ', '')
              : 'Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác.';
        } else if (errorStr.contains('email-already-in-use')) {
          errorMessage = 'Email đã được sử dụng trong Firebase Auth. Vui lòng dùng email khác.';
        } else if (errorStr.contains('weak-password')) {
          errorMessage = 'Mật khẩu quá yếu. Vui lòng dùng mật khẩu có ít nhất 6 ký tự.';
        } else if (errorStr.contains('invalid-email')) {
          errorMessage = 'Email không hợp lệ. Vui lòng kiểm tra lại.';
        } else if (errorStr.contains('network') || errorStr.contains('connection')) {
          errorMessage = 'Lỗi kết nối. Vui lòng kiểm tra internet và thử lại.';
        } else if (errorStr.contains('permission') || errorStr.contains('denied')) {
          errorMessage = 'Không có quyền thực hiện. Vui lòng kiểm tra quyền truy cập.';
        }
        
        debugPrint('Error creating user: $e');
        debugPrint('Error message: $errorMessage');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa nhân viên' : 'Thêm nhân viên'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _handleSave,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ và tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Tên đăng nhập *',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
              enabled: !isEdit, // Cannot change username when editing
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên đăng nhập';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!value.contains('@')) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: isEdit ? 'Mật khẩu mới (để trống nếu không đổi)' : 'Mật khẩu *',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (!isEdit && (value == null || value.isEmpty)) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value != null && value.isNotEmpty && value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Role
            DropdownButtonFormField<app_user.UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Vai trò *',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
              ),
              items: app_user.UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role == app_user.UserRole.admin ? 'Admin' : 'Nhân viên'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Cập nhật' : 'Tạo tài khoản'),
            ),
          ],
        ),
      ),
    );
  }
}

