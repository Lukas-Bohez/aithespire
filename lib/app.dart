import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_constants.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/widgets/app_scaffold.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';
import 'presentation/screens/models/models_screen.dart';
import 'presentation/screens/sessions/sessions_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/setup/android_setup_screen.dart';
import 'presentation/screens/setup/lan_setup_screen.dart';
import 'presentation/screens/setup/termux_setup_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/chat',
            builder: (context, state) {
              final extraModel = state.extra is String ? state.extra as String : null;
              return ChatScreen(initialModel: extraModel);
            },
          ),
          GoRoute(path: '/models', builder: (context, state) => const ModelsScreen()),
          GoRoute(path: '/sessions', builder: (context, state) => const SessionsScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const AndroidSetupScreen(),
      ),
      GoRoute(
        path: '/setup/termux',
        builder: (context, state) => const TermuxSetupScreen(),
      ),
      GoRoute(
        path: '/setup/lan',
        builder: (context, state) => const LanSetupScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D3BF3),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ).copyWith(
          bodyMedium: GoogleFonts.inter(
            fontSize: appSettings.fontSize,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D3BF3),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey.shade900,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ).copyWith(
          bodyMedium: GoogleFonts.inter(
            fontSize: appSettings.fontSize,
          ),
        ),
      ),
      themeMode: appSettings.themeMode,
      routerConfig: router,
    );
  }
}
