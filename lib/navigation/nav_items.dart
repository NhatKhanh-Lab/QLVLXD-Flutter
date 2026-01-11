import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/home_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/customer_list_screen.dart';
import '../screens/supplier_list_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/user_management_screen.dart';
import '../providers/auth_provider.dart';

class NavItem {
  final String label;
  final IconData icon;
  final Widget Function() pageBuilder;
  final bool adminOnly; // Only show for admin

  const NavItem({
    required this.label,
    required this.icon,
    required this.pageBuilder,
    this.adminOnly = false,
  });
}

/// Central place to define all bottom navigation items and their destination pages.
class AppNavItems {
  static List<NavItem> getItems(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.isAdmin;

    return [
      NavItem(
        label: 'Trang chủ',
        icon: Icons.home_outlined,
        pageBuilder: () => const HomeScreen(),
      ),
      NavItem(
        label: 'Sản phẩm',
        icon: Icons.inventory_2_outlined,
        pageBuilder: () => const ProductListScreen(),
      ),
      NavItem(
        label: 'Khách hàng',
        icon: Icons.people_alt_outlined,
        pageBuilder: () => const CustomerListScreen(),
      ),
      NavItem(
        label: 'Nhà C.cấp',
        icon: Icons.local_shipping_outlined,
        pageBuilder: () => const SupplierListScreen(),
        adminOnly: true, // Only admin can manage suppliers
      ),
      NavItem(
        label: 'Nhân viên',
        icon: Icons.people_outline,
        pageBuilder: () => const UserManagementScreen(),
        adminOnly: true, // Only admin can manage users
      ),
      NavItem(
        label: 'Cài đặt',
        icon: Icons.settings_outlined,
        pageBuilder: () => const SettingsScreen(),
      ),
    ].where((item) => !item.adminOnly || isAdmin).toList();
  }

  // For backward compatibility - returns all items (used in AppShell)
  static List<NavItem> get items => [
        NavItem(
          label: 'Trang chủ',
          icon: Icons.home_outlined,
          pageBuilder: () => const HomeScreen(),
        ),
        NavItem(
          label: 'Sản phẩm',
          icon: Icons.inventory_2_outlined,
          pageBuilder: () => const ProductListScreen(),
        ),
        NavItem(
          label: 'Khách hàng',
          icon: Icons.people_alt_outlined,
          pageBuilder: () => const CustomerListScreen(),
        ),
        NavItem(
          label: 'Nhà C.cấp',
          icon: Icons.local_shipping_outlined,
          pageBuilder: () => const SupplierListScreen(),
          adminOnly: true,
        ),
        NavItem(
          label: 'Nhân viên',
          icon: Icons.people_outline,
          pageBuilder: () => const UserManagementScreen(),
          adminOnly: true,
        ),
        NavItem(
          label: 'Cài đặt',
          icon: Icons.settings_outlined,
          pageBuilder: () => const SettingsScreen(),
        ),
      ];
}

