import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _items = <_NavItem>[
    _NavItem('Trang chủ', Icons.home_outlined),
    _NavItem('Kho hàng', Icons.inventory_2_outlined),
    _NavItem('Bán hàng', Icons.receipt_long_outlined),
    _NavItem('Nhập hàng', Icons.local_shipping_outlined),
    _NavItem('Đối tác', Icons.groups_2_outlined),
    _NavItem('Báo cáo', Icons.bar_chart_outlined),
    _NavItem('Cài đặt', Icons.settings_outlined),
  ];

  // ✅ Pages: tab 0 là trang GIỚI THIỆU APP, còn lại placeholder
  List<Widget> get _pages => const [
        IntroHomePage(),
        _PlaceholderPage(title: 'Kho hàng'),
        _PlaceholderPage(title: 'Bán hàng'),
        _PlaceholderPage(title: 'Nhập hàng'),
        _PlaceholderPage(title: 'Đối tác'),
        _PlaceholderPage(title: 'Báo cáo'),
        _PlaceholderPage(title: 'Cài đặt'),
      ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final isMobile = w < 760;
    final isDesktop = w >= 1100;

    return Scaffold(
      body: Row(
        children: [
          // LEFT NAV (desktop/tablet)
          if (!isMobile)
            _LeftRail(
              index: _index,
              items: _items,
              extended: isDesktop,
              onChanged: (i) => setState(() => _index = i),
            ),

          // MAIN
          Expanded(
            child: Column(
              children: [
                // TOP NAV (giống mẫu) chỉ hiện khi desktop/tablet
                if (!isMobile)
                  _TopTabs(
                    index: _index,
                    items: _items,
                    onChanged: (i) => setState(() => _index = i),
                  ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _pages[_index],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ✅ BOTTOM NAV (mobile) + màu xanh dương đậm
      bottomNavigationBar: isMobile
          ? NavigationBarTheme(
              data: const NavigationBarThemeData(
                height: 74,
                backgroundColor: Color(0xFF0D47A1), // xanh dương đậm
                indicatorColor: Color(0xFF1565C0), // tab active
                labelTextStyle: WidgetStatePropertyAll(
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                iconTheme: WidgetStatePropertyAll(
                  IconThemeData(color: Colors.white),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _index.clamp(0, 4), // mobile show 5 tab chính
                onDestinationSelected: (i) {
                  // Tab "Thêm" chỉ mở menu, không đổi trang
                  if (i == 4) {
                    _openMoreMenu(context);
                    return;
                  }
                  setState(() => _index = i);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: 'Kho',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: 'Bán',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.local_shipping_outlined),
                    selectedIcon: Icon(Icons.local_shipping),
                    label: 'Nhập',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.more_horiz),
                    selectedIcon: Icon(Icons.more_horiz),
                    label: 'Thêm',
                  ),
                ],
              ),
            )
          : null,

      // ✅ FAB (mobile): chuyển sang góc phải để KHÔNG che icon
      floatingActionButton: isMobile
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              onPressed: () => _openQuickCreate(context),
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ✅ FAB menu: đúng nhu cầu VLXD
  void _openQuickCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Tạo hóa đơn bán'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Tạo đơn nhập hàng'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Thêm sản phẩm'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 1);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Menu “Thêm” (đối tác/báo cáo/cài đặt)
  void _openMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.groups_2_outlined),
                title: const Text('Đối tác (Khách / NCC)'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 4);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart_outlined),
                title: const Text('Báo cáo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 5);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Cài đặt'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 6);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

class _TopTabs extends StatelessWidget {
  final int index;
  final List<_NavItem> items;
  final ValueChanged<int> onChanged;

  const _TopTabs({
    required this.index,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == index;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onChanged(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(items[i].icon, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _LeftRail extends StatelessWidget {
  final int index;
  final List<_NavItem> items;
  final bool extended;
  final ValueChanged<int> onChanged;

  const _LeftRail({
    required this.index,
    required this.items,
    required this.extended,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: onChanged,
      extended: extended,
      labelType: extended ? null : NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: FloatingActionButton.small(
          onPressed: () {},
          child: const Icon(Icons.menu),
        ),
      ),
      destinations: items
          .map(
            (e) => NavigationRailDestination(
              icon: Icon(e.icon),
              selectedIcon: Icon(e.icon),
              label: Text(e.label),
            ),
          )
          .toList(),
    );
  }
}

/// ✅ TRANG GIỚI THIỆU APP (Home)
class IntroHomePage extends StatelessWidget {
  const IntroHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      children: [
        // Hero banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppBadge(),
              SizedBox(height: 12),
              Text(
                'Quản lý & Bán Vật Liệu Xây Dựng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8),

            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Tính năng nổi bật',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),

        const _FeatureCard(
          icon: Icons.inventory_2_outlined,
          title: 'Kho hàng & tồn kho',
          desc: 'Theo dõi tồn, cảnh báo sắp hết, quản lý giá bán & đơn vị tính.',
        ),
        const _FeatureCard(
          icon: Icons.receipt_long_outlined,
          title: 'Bán hàng / Hoá đơn',
          desc: 'Tạo hoá đơn nhanh, xem lịch sử giao dịch, xuất/in hoá đơn.',
        ),
        const _FeatureCard(
          icon: Icons.local_shipping_outlined,
          title: 'Nhập hàng',
          desc: 'Tạo đơn nhập, cập nhật tồn tự động, theo dõi nhà cung cấp.',
        ),
        const _FeatureCard(
          icon: Icons.groups_2_outlined,
          title: 'Đối tác (Khách / NCC)',
          desc: 'Quản lý thông tin, công nợ và lịch sử mua/bán theo đối tác.',
        ),
        const _FeatureCard(
          icon: Icons.bar_chart_outlined,
          title: 'Báo cáo',
          desc: 'Doanh thu, hàng bán chạy, tổng quan theo thời gian.',
        ),

        const SizedBox(height: 12),

        // CTA
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tip: Bấm tab “Kho” để bắt đầu quản lý sản phẩm')),
                  );
                },
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Bắt đầu'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo: Hướng dẫn sẽ bổ sung sau')),
                  );
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('Hướng dẫn'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: const Row(
            children: [
              Icon(Icons.offline_bolt_outlined),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Offline-first: dữ liệu lưu cục bộ (Hive). Khi cần có thể bật Firebase để đồng bộ nhiều thiết bị.',
                  style: TextStyle(height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppBadge extends StatelessWidget {
  const _AppBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.apartment_outlined,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}


class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(title),
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
