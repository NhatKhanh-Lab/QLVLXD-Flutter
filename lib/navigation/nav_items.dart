import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/customer_list_screen.dart';
import '../screens/supplier_list_screen.dart';
import '../screens/settings_screen.dart';

class NavItem {
  final String label;
  final IconData icon;
  final Widget page;

  const NavItem({
    required this.label,
    required this.icon,
    required this.page,
  });
}

/// Central place to define all bottom navigation items and their destination pages.
class AppNavItems {
  static const List<NavItem> items = [
    NavItem(
      label: 'Trang chủ',
      icon: Icons.home_outlined,
      page: HomeScreen(),
    ),
    NavItem(
      label: 'Sản phẩm',
      icon: Icons.inventory_2_outlined,
      page: ProductListScreen(),
    ),
    NavItem(
      label: 'Khách hàng',
      icon: Icons.people_alt_outlined,
      page: CustomerListScreen(),
    ),
    NavItem(
      label: 'Nhà C.cấp',
      icon: Icons.local_shipping_outlined,
      page: SupplierListScreen(),
    ),
    NavItem(
      label: 'Cài đặt',
      icon: Icons.settings_outlined,
      page: SettingsScreen(),
    ),
  ];
}

