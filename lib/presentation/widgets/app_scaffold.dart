import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ollama_status_banner.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({
    super.key,
    required this.child,
  });

  static const List<_NavItem> _navItems = [
    _NavItem(route: '/chat', icon: Icons.chat_bubble_outline, label: 'Chats'),
    _NavItem(route: '/models', icon: Icons.storage_outlined, label: 'Models'),
    _NavItem(route: '/sessions', icon: Icons.request_page_outlined, label: 'Sessions'),
    _NavItem(route: '/settings', icon: Icons.settings_outlined, label: 'Settings'),
  ];

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _navItems.indexWhere((item) => item.route == path);
    return index < 0 ? 0 : index;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    if (index < 0 || index >= _navItems.length) return;
    context.go(_navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final selectedIndex = _selectedIndex(context);

    if (isDesktop) {
      return Scaffold(
        body: Column(
          children: [
            const OllamaStatusBanner(),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 270,
                    child: NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (idx) => _onDestinationSelected(context, idx),
                      labelType: NavigationRailLabelType.all,
                      groupAlignment: -1.0,
                      leading: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'AIthespire',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      destinations: _navItems
                          .map(
                            (item) => NavigationRailDestination(
                              icon: Icon(item.icon),
                              label: Text(item.label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const OllamaStatusBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onDestinationSelected(context, idx),
        destinations: _navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final String route;
  final IconData icon;
  final String label;

  const _NavItem({required this.route, required this.icon, required this.label});
}
