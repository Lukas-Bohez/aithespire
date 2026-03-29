import 'package:flutter/material.dart';
import 'ollama_status_banner.dart';
import '../screens/home/home_screen.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final void Function(int)? onIndexChanged;

  const AppScaffold({
    super.key,
    required this.child,
    this.selectedIndex = 0,
    this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

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
                      onDestinationSelected: onIndexChanged,
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
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.chat_bubble_outline),
                          label: Text('Chats'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.storage_outlined),
                          label: Text('Models'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings_outlined),
                          label: Text('Settings'),
                        ),
                      ],
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
        onDestinationSelected: onIndexChanged ?? (_) {},
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            label: 'Models',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
