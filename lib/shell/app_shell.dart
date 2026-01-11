import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/nav_items.dart';
import '../providers/auth_provider.dart';

/// Root shell for the app that hosts the bottom navigation bar and main tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final List<int> _tabHistory = [];

  late List<NavItem> _navItems;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _updateNavItems();
  }

  void _updateNavItems() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.isAdmin;

    // Filter nav items based on user role
    _navItems = AppNavItems.items.where((item) => !item.adminOnly || isAdmin).toList();

    // Use PageStorageKeys so each tab preserves its own scroll/form state.
    _pages = List<Widget>.generate(
      _navItems.length,
      (index) => KeyedSubtree(
        key: PageStorageKey<String>('tab_$index'),
        child: _navItems[index].pageBuilder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild nav items when auth state changes (user role might change)
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Update nav items if user role changed
        final isAdmin = authProvider.isAdmin;
        final newNavItems = AppNavItems.items.where((item) => !item.adminOnly || isAdmin).toList();
        
        // Rebuild pages if nav items changed
        if (newNavItems.length != _navItems.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _navItems = newNavItems;
              _pages = List<Widget>.generate(
                _navItems.length,
                (index) => KeyedSubtree(
                  key: PageStorageKey<String>('tab_$index'),
                  child: _navItems[index].pageBuilder(),
                ),
              );
              // Reset to first tab if current index is out of bounds
              if (_currentIndex >= _navItems.length) {
                _currentIndex = 0;
              }
            });
          });
        }

        return _buildScaffold(context);
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  void _onTabSelected(int newIndex) {
    if (newIndex == _currentIndex) {
      return;
    }
    setState(() {
      _tabHistory.add(_currentIndex);
      _currentIndex = newIndex;
    });
  }

  Future<bool> _onWillPop() async {
    if (_tabHistory.isNotEmpty) {
      setState(() {
        _currentIndex = _tabHistory.removeLast();
      });
      return false;
    }
    // Let system handle back (will close the app when on root).
    return true;
  }

  Widget _buildBottomBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabSelected,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: colorScheme.secondary,
              unselectedItemColor:
                  colorScheme.onSurface.withOpacity(0.6),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
              ),
              iconSize: 24,
              items: [
                for (final item in _navItems)
                  BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

