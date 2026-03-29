import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/chat_provider.dart';
import '../../presentation/providers/dio_provider.dart';
import 'ollama_status_banner.dart';

class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({
    super.key,
    required this.child,
  });

  static const List<_NavItem> _navItems = [
    _NavItem(
      route: '/chat',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chats',
    ),
    _NavItem(
      route: '/models',
      icon: Icons.storage_outlined,
      activeIcon: Icons.storage,
      label: 'Models',
    ),
    _NavItem(
      route: '/sessions',
      icon: Icons.request_page_outlined,
      activeIcon: Icons.request_page,
      label: 'Sessions',
    ),
    _NavItem(
      route: '/settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
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

  Widget _buildSidebarItem(BuildContext context, _NavItem item, bool isActive) {
    return Material(
      color: isActive ? const Color(0xFFE8EAFE) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go(item.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(isActive ? item.activeIcon : item.icon,
                  color: isActive ? const Color(0xFF3D3BF3) : Colors.grey[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: isActive ? Colors.black : Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _starIcon() {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _SparkPainter(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final selectedIndex = _selectedIndex(context);

    final sidebar = Container(
      width: 220,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _starIcon(),
                const SizedBox(width: 8),
                const Text(
                  'AIthespire',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () {
                ref.read(chatProvider.notifier).resetSession();
                context.go('/chat');
              },
              icon: const Icon(Icons.add),
              label: const Text('New Chat'),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, idx) {
                final item = _navItems[idx];
                final isActive = idx == selectedIndex;
                return _buildSidebarItem(context, item, isActive);
              },
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemCount: _navItems.length,
            ),
          ),
          FutureBuilder<bool>(
            future: ref.read(ollamaRemoteDatasourceProvider).checkVersion(),
            builder: (context, snapshot) {
              final online = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  onTap: () => context.go('/settings'),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: online ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        online ? 'Ollama online' : 'Ollama offline',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Scaffold(
        body: Column(
          children: [
            const OllamaStatusBanner(),
            Expanded(
              child: Row(
                children: [
                  sidebar,
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
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _SparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3D3BF3);
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    // 4-pointed star
    path.moveTo(center.dx, 0);
    path.lineTo(center.dx + size.width * 0.15, center.dy - size.height * 0.05);
    path.lineTo(size.width, center.dy);
    path.lineTo(center.dx + size.width * 0.15, center.dy + size.height * 0.05);
    path.lineTo(center.dx, size.height);
    path.lineTo(center.dx - size.width * 0.15, center.dy + size.height * 0.05);
    path.lineTo(0, center.dy);
    path.lineTo(center.dx - size.width * 0.15, center.dy - size.height * 0.05);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
