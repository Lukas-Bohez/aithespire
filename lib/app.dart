import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';
import 'presentation/screens/models/models_screen.dart';
import 'presentation/screens/sessions/sessions_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/setup/android_setup_screen.dart';
import 'presentation/screens/setup/lan_setup_screen.dart';
import 'presentation/screens/setup/termux_setup_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(
        path: '/models',
        builder: (context, state) => const ModelsScreen(),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const SessionsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),      GoRoute(
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
      ),    ],
  );

  @override
  Widget build(BuildContext context) {
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
        textTheme: GoogleFonts.interTextTheme(),
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
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
