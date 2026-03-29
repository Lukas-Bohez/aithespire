import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_the_spire/data/datasources/ollama_remote_datasource.dart';
import '../../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _remote = OllamaRemoteDatasource();

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final online = await _remote.checkVersion();
        if (!online && mounted) {
          context.go('/setup');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedIndex: 0,
      onIndexChanged: (index) {
        switch (index) {
          case 0:
            context.go('/sessions');
            break;
          case 1:
            context.go('/models');
            break;
          case 2:
            context.go('/settings');
            break;
        }
      },
      child: const Center(child: Text('Welcome to AIthespire')),
    );
  }
}
