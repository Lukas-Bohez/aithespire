import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_the_spire/presentation/providers/dio_provider.dart';
import '../../widgets/app_scaffold.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final _remote = ref.read(ollamaRemoteDatasourceProvider);

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
    return const Center(child: Text('Welcome to AIthespire'));
  }
}
